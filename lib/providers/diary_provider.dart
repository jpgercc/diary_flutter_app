import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../services/diary_service.dart';

class DiaryProvider with ChangeNotifier {
  late final DiaryService _diaryService;
  List<Entry> _entries = [];
  bool _isLoading = false;
  bool _isConfigured = false;
  bool _isInitialized = false;

  List<Entry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isConfigured => _isConfigured;
  bool get isInitialized => _isInitialized;

  DiaryProvider() {
    _diaryService = DiaryService();
    _init();
  }

  Future<void> _init() async {
    _setLoading(true);
    _isConfigured = await _diaryService.isCloudConfigured();
    
    // 1. Carrega o que tem no celular
    await _loadEntries(); 

    // 2. CORREÇÃO CRÍTICA:
    // Se o celular estiver vazio (instalação nova) E tivermos nuvem configurada,
    // OBRIGA a esperar o download da nuvem antes de iniciar.
    if (_entries.isEmpty && _isConfigured) {
       print("Cache vazio. Forçando download da nuvem antes de iniciar...");
       await syncCloud(); 
    } else if (_isConfigured) {
       // Se já tem dados locais, inicia rápido e atualiza em background
       print("Cache encontrado. Iniciando e sincronizando em background...");
       syncCloud();
    }

    _isInitialized = true;
    _setLoading(false);
  }

  Future<void> _loadEntries() async {
    _entries = await _diaryService.loadEntries();
    _sortEntries();
    notifyListeners();
  }

  Future<void> syncCloud() async {
    try {
      // Sincroniza e atualiza a lista
      await _diaryService.sync();
      // Recarrega do disco para a memória
      await _loadEntries(); 
    } catch (e) {
      print("Erro no sync: $e");
    }
  }

  Future<void> addOrUpdate(Entry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      _entries[index] = entry;
    } else {
      _entries.add(entry);
    }
    
    _sortEntries();
    notifyListeners();
    
    await _diaryService.saveEntries(_entries);
  }

  Future<void> delete(int id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _diaryService.saveEntries(_entries);
  }
  
  void _sortEntries() {
    _entries.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
