import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import 'drive_service.dart';

class DiaryService {
  final CloudService _cloudService;
  static const String _localCacheKey = 'diary_entries_cache';

  DiaryService() : _cloudService = CloudService();

  Future<bool> isCloudConfigured() => _cloudService.isConfigured();

  /// Carrega as entradas.
  /// Retorna primeiro o cache local para ser rápido.
  Future<List<Entry>> loadEntries() async {
    // 1. Carrega local
    final localEntries = await _loadLocalCache();
    
    // 2. Tenta sincronizar (silenciosamente) se tiver internet/config
    _syncWithCloud(); 

    return localEntries;
  }

  /// Método público para forçar sincronização
  Future<List<Entry>> sync() async {
    await _syncWithCloud();
    return await _loadLocalCache();
  }

  Future<void> _syncWithCloud() async {
    if (await _cloudService.isConfigured()) {
      final cloudContent = await _cloudService.readDiaryFile();
      if (cloudContent != null && cloudContent.isNotEmpty) {
        // Nuvem ganhou. Atualiza local.
        await _saveLocalCache(cloudContent);
      }
    }
  }

  /// Salva as entradas
  Future<void> saveEntries(List<Entry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    final content = jsonEncode(jsonList);

    // 1. Salva localmente (garantido)
    await _saveLocalCache(content);

    // 2. Tenta salvar na nuvem
    if (await _cloudService.isConfigured()) {
      await _cloudService.saveDiaryFile(content);
    }
  }

  Future<void> _saveLocalCache(String content) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localCacheKey, content);
  }

  Future<List<Entry>> _loadLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString(_localCacheKey);
    if (content != null && content.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((e) => Entry.fromJson(e)).toList();
      } catch (e) {
        print('Erro ao ler cache local: $e');
      }
    }
    return [];
  }
}
