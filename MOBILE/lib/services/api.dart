import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/divida.dart';
import '../models/contato.dart';

class ApiService {
  static const String baseUrl = 'https://projeto-mobile-dsm5.onrender.com'; // Para api produção
  //static const String baseUrl = 'http://192.168.100.253:3000'; // Para api local

  // Dívidas
  static Future<List<Divida>> buscarDividas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dividas'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Divida.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar dívidas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> salvarDivida(Divida divida) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dividas'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'valor': divida.valor,
          'numeroConta': divida.numeroConta,
          'descricao': divida.descricao,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Erro ao salvar dívida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> atualizarDivida(Divida divida) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/dividas/${divida.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'valor': divida.valor,
          'numeroConta': divida.numeroConta,
          'descricaoDivida': divida.descricao,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar dívida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> atualizarStatusDivida(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/dividas/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> deletarDivida(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/dividas/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao deletar dívida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  // Contatos
  static Future<List<Contato>> buscarContatos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/contatos'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Contato.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao buscar contatos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> salvarContato(Contato contato) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/contatos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': contato.nome,
          'numeroConta': contato.numeroConta,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Erro ao salvar contato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> atualizarContato(Contato contato) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/contatos/${contato.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nome': contato.nome,
          'numeroConta': contato.numeroConta,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar contato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }

  static Future<void> deletarContato(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/contatos/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao deletar contato: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com a API: $e');
    }
  }
}