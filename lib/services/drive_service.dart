import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CloudService {
  static const String _githubToken = 'SEU_TOKEN_AQUI';
  static const String _fileName = 'meu_diario_backup.json';
  static const String _prefGistId = 'github_gist_id';

  // Variável para guardar o log de erros e mostrar na tela
  static String debugLog = "";

  void _log(String message) {
    print(message);
    debugLog += "$message\n";
  }

  Map<String, String> get _headers => {
    'Authorization': 'token $_githubToken',
    'Accept': 'application/vnd.github.v3+json',
    'Content-Type': 'application/json',
  };

  Future<bool> isConfigured() async => _githubToken.isNotEmpty;

  /// Busca o ID do Gist se existir
  Future<String?> _findExistingGistId() async {
    _log("Procurando Gist no GitHub...");
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/gists'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> gists = jsonDecode(response.body);
        _log("Encontrados ${gists.length} Gists na conta.");
        
        for (var gist in gists) {
          final files = gist['files'] as Map<String, dynamic>;
          _log("Verificando Gist ${gist['id']} - Arquivos: ${files.keys.join(', ')}");
          
          if (files.containsKey(_fileName)) {
            _log("Arquivo encontrado! ID: ${gist['id']}");
            return gist['id'];
          }
        }
        _log("Arquivo '$_fileName' NÃO encontrado em nenhum Gist.");
      } else {
        _log("Erro ao buscar Gists: ${response.statusCode}");
      }
    } catch (e) {
      _log("Exceção ao buscar Gists: $e");
    }
    return null;
  }

  /// Lê o arquivo da nuvem
  Future<String?> readDiaryFile() async {
    _log("Iniciando leitura da nuvem...");
    if (_githubToken.isEmpty) {
      _log("Erro: Token vazio.");
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // FORÇAR BUSCA NA PRIMEIRA VEZ (Ignorar cache se estiver dando erro)
      // Comentei a leitura do cache para forçar ele a procurar o novo arquivo que você criou
      // String? gistId = prefs.getString(_prefGistId);
      String? gistId = null; 

      if (gistId == null) {
        gistId = await _findExistingGistId();
        if (gistId != null) {
          await prefs.setString(_prefGistId, gistId);
        }
      }

      if (gistId == null) {
        _log("Falha fatal: Nenhum ID de Gist encontrado.");
        return null;
      }

      _log("Baixando conteúdo do Gist: $gistId");
      final response = await http.get(
        Uri.parse('https://api.github.com/gists/$gistId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as Map<String, dynamic>;
        if (files.containsKey(_fileName)) {
          final content = files[_fileName]['content'];
          _log("Sucesso! Baixado ${content.length} caracteres.");
          return content;
        } else {
          _log("Erro: Gist existe mas o arquivo sumiu dentro dele.");
        }
      } else {
        _log("Erro HTTP ao ler: ${response.statusCode}");
      }
      return null;
    } catch (e) {
      _log("Exceção de leitura: $e");
      return null;
    }
  }

  /// Salva na nuvem
  Future<bool> saveDiaryFile(String content) async {
    _log("Salvando na nuvem...");
    if (_githubToken.isEmpty) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? gistId = prefs.getString(_prefGistId);

      if (gistId == null) {
        gistId = await _findExistingGistId();
        if (gistId != null) await prefs.setString(_prefGistId, gistId);
      }

      http.Response response;

      final body = jsonEncode({
        "description": "Backup Automático do Diário",
        "public": false, 
        "files": {
          _fileName: { "content": content }
        }
      });

      if (gistId == null) {
        _log("Criando NOVO Gist...");
        response = await http.post(
          Uri.parse('https://api.github.com/gists'),
          headers: _headers,
          body: body,
        );
      } else {
        _log("Atualizando Gist existente...");
        response = await http.patch(
          Uri.parse('https://api.github.com/gists/$gistId'),
          headers: _headers,
          body: body,
        );
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(_prefGistId, data['id']);
        _log("Salvo com sucesso!");
        return true;
      }
      _log("Erro ao salvar: ${response.statusCode} - ${response.body}");
      return false;
    } catch (e) {
      _log("Exceção ao salvar: $e");
      return false;
    }
  }
}
