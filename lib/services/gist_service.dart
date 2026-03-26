import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudService {
  // Acessa o token via variáveis de ambiente
  static String get _githubToken => dotenv.env['GITHUB_TOKEN'] ?? '';
  
  static const String _fileName = 'meu_diario_backup.json';
  static const String _prefGistId = 'github_gist_id';

  Map<String, String> get _headers => {
    'Authorization': 'token $_githubToken',
    'Accept': 'application/vnd.github.v3+json',
    'Content-Type': 'application/json',
  };

  Future<bool> isConfigured() async => _githubToken.isNotEmpty;

  /// Busca o ID do Gist se existir na conta do usuário
  Future<String?> _findExistingGistId() async {
    debugPrint("CloudService: Buscando ID do Gist na API...");
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/gists'),
        headers: _headers,
      );

      debugPrint("CloudService: Busca de Gists retornou status ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> gists = jsonDecode(response.body);
        for (var gist in gists) {
          final files = gist['files'] as Map<String, dynamic>;
          if (files.containsKey(_fileName)) {
            debugPrint("CloudService: Gist encontrado com ID: ${gist['id']}");
            return gist['id'];
          }
        }
        debugPrint("CloudService: Nenhum Gist encontrado com o arquivo $_fileName");
      } else {
        debugPrint("CloudService: Erro na busca de Gists. Corpo: ${response.body}");
      }
    } catch (e) {
      debugPrint("Erro ao buscar Gists: $e");
    }
    return null;
  }

  /// Resolve o ID do Gist: .env > SharedPreferences > API Discovery
  Future<String?> _resolveGistId() async {
    // 1. Tenta do .env
    String? envId = dotenv.env['GIST_ID'];
    if (envId != null && envId.isNotEmpty) {
       return envId;
    }

    final prefs = await SharedPreferences.getInstance();
    String? gistId = prefs.getString(_prefGistId);

    // 2. Tenta do SharedPreferences
    if (gistId != null) {
      debugPrint("CloudService: Usando ID do Gist salvo localmente: $gistId");
      return gistId;
    }

    // 3. Tenta descobrir na API
    debugPrint("CloudService: ID do Gist não encontrado localmente. Tentando descobrir...");
    gistId = await _findExistingGistId();
    if (gistId != null) {
      await prefs.setString(_prefGistId, gistId);
    }
    return gistId;
  }

  /// Lê o arquivo da nuvem
  Future<String?> readDiaryFile() async {
    if (_githubToken.isEmpty) return null;

    try {
      final gistId = await _resolveGistId();

      if (gistId == null) {
        debugPrint("CloudService: Impossível ler. ID do Gist é nulo.");
        return null; // Nenhum backup encontrado
      }

      debugPrint("CloudService: Lendo conteúdo do Gist $gistId...");
      final response = await http.get(
        Uri.parse('https://api.github.com/gists/$gistId'),
        headers: _headers,
      );

      debugPrint("CloudService: Leitura do Gist retornou status ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as Map<String, dynamic>;
        if (files.containsKey(_fileName)) {
          debugPrint("CloudService: Conteúdo lido com sucesso.");
          return files[_fileName]['content'];
        } else {
          debugPrint("CloudService: O arquivo $_fileName não existe neste Gist.");
        }
      } else {
        debugPrint("CloudService: Erro ao ler Gist. Corpo: ${response.body}");
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao ler do GitHub: $e");
      return null;
    }
  }

  /// Salva (Cria ou Atualiza) o Gist
  Future<bool> saveDiaryFile(String content) async {
    if (_githubToken.isEmpty) return false;

    try {
      String? gistId = await _resolveGistId();

      http.Response response;

      final body = jsonEncode({
        "description": "Backup Automático do Diário",
        "public": false, // Secreto
        "files": {
          _fileName: { "content": content }
        }
      });

      if (gistId == null) {
        debugPrint("CloudService: Criando novo Gist...");
        response = await http.post(
          Uri.parse('https://api.github.com/gists'),
          headers: _headers,
          body: body,
        );
      } else {
        debugPrint("CloudService: Atualizando Gist $gistId...");
        response = await http.patch(
          Uri.parse('https://api.github.com/gists/$gistId'),
          headers: _headers,
          body: body,
        );
      }

      debugPrint("CloudService: Save retornou status ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Atualiza o ID localmente caso tenhamos acabado de criar
        final newId = data['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefGistId, newId);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro ao salvar no GitHub: $e");
      return false;
    }
  }
}
