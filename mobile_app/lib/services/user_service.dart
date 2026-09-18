import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class UserService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchBasicUser(int id) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/$id/basic'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load user');
    }
    return data['user'];
  }
}