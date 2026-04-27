import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mycelium/core/stores/api_store.dart';

class ApiService {
  final ApiStore apiStore;
  final Duration timeout;

  ApiService(this.apiStore, {this.timeout = const Duration(seconds: 5)});

  Future<http.Response> get(String path) async {
    return await http.get(
      Uri.parse("${apiStore.baseUrl}$path"),
    ).timeout(timeout);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse("${apiStore.baseUrl}$path"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    ).timeout(timeout);
  }

  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    return await http.patch(
      Uri.parse("${apiStore.baseUrl}$path"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    ).timeout(timeout);
  }

  Future<http.Response> delete(String path) async {
    return await http.delete(
      Uri.parse("${apiStore.baseUrl}$path"),
    ).timeout(timeout);
  }

  Future<bool> checkReachability() async {
    try {
      final response = await get("/health");
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
