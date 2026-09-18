import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Change ONLY this line depending on where you're testing:
  // Android emulator:      http://10.0.2.2:5000/api
  // Physical phone (WiFi): http://YOUR_PC_LAN_IP:5000/api
  static const String baseUrl = 'http://172.16.17.120:5000/api';

  // Derived automatically — never edit this separately, it just strips '/api'.
  static String get serverUrl => baseUrl.substring(0, baseUrl.length - 4);

  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Registration failed');
    }
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login failed');
    }
    await storage.write(key: 'auth_token', value: data['token']);
    return data;
  }

  Future<Map<String, dynamic>> fetchMe() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to fetch profile');
    }
    return data;
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
  }
}