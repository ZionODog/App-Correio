// lib/services/api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiService {
  // Função para realizar o login
  Future<Map<String, dynamic>> login(String re, String password) async {
    // A URL está correta, sem o /api
    final url = Uri.parse('$apiUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'re': re, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sucesso: retorna o mapa com success = true e os dados do usuário
        return {'success': true, 'user': data['user']};
      } else {
        // Falha: retorna o mapa com success = false e a mensagem de erro
        return {'success': false, 'message': data['error'] ?? 'Falha no login'};
      }
    } catch (e) {
      // Erro de conexão
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
    String re,
    String password,
    String location,
  ) async {
    final url = Uri.parse('$apiUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          're': re,
          'password': password,
          'location': location,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // 201 = Created (Sucesso)
        return {'success': true, 'message': data['message']};
      } else {
        // Pega a mensagem de erro da API (ex: "Usuário já existe")
        return {
          'success': false,
          'message': data['error'] ?? 'Falha ao registrar',
        };
      }
    } catch (e) {
      // Erro de conexão
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<Map<String, dynamic>> addMalote(Map<String, String> maloteInfo) async {
    final url = Uri.parse('$apiUrl/malotes');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(maloteInfo),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<List<String>> getLocalidades() async {
    final url = Uri.parse('$apiUrl/localidades');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decodifica a resposta JSON e converte para uma lista de Strings
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item.toString()).toList();
      } else {
        // Se a resposta não for OK, lança um erro
        throw Exception('Falha ao carregar localidades');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Map<String, dynamic>> atualizarMalote(
    String codigo,
    String usuarioRe,
    String localizacao,
  ) async {
    final url = Uri.parse('$apiUrl/malotes/atualizar');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'codigo': codigo, // <-- Mude de 'qr_hash' para 'codigo'
          'usuario_re': usuarioRe,
          'localizacao_atual': localizacao,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['error']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro de conexão: $e'};
    }
  }

  Future<List<dynamic>> getMalotes({String? searchTerm}) async {
    // Por padrão, sempre busca os que não foram entregues
    String url = '$apiUrl/malotes?status_ne=Entregue'; // <-- Filtro padrão
    if (searchTerm != null && searchTerm.isNotEmpty) {
      // Se houver um termo de busca, remove o filtro padrão e usa o de busca
      url = '$apiUrl/malotes?search=$searchTerm';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar malotes');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // Função para buscar o histórico de um malote
  Future<List<dynamic>> getMaloteHistorico(String barcode) async {
    final url = '$apiUrl/malotes/$barcode/historico';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar histórico do malote');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
