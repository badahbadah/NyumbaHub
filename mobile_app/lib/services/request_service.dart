import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/house_request.dart';
import 'api_service.dart';

class RequestService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<List<HouseRequest>> fetchRequests({String? city, String? propertyType, String? status}) async {
    final queryParams = <String, String>{};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (propertyType != null) queryParams['property_type'] = propertyType;
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('${ApiService.baseUrl}/requests').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load requests');
    final List requestsJson = data['requests'];
    return requestsJson.map((json) => HouseRequest.fromJson(json)).toList();
  }

  Future<List<HouseRequest>> fetchMyRequests() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/requests/mine'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load your requests');
    final List requestsJson = data['requests'];
    return requestsJson.map((json) => HouseRequest.fromJson(json)).toList();
  }

  Future<HouseRequest> createRequest({
    required String propertyType,
    String? targetArea,
    required String city,
    required double budgetAmount,
    String? budgetPeriod,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/requests'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'property_type': propertyType, 'target_area': targetArea, 'city': city,
        'budget_amount': budgetAmount, 'budget_period': budgetPeriod, 'notes': notes,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to broadcast request');
    return HouseRequest.fromJson(data['request']);
  }

  Future<void> closeRequest(int id) async {
    final response = await http.patch(Uri.parse('${ApiService.baseUrl}/requests/$id/close'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to close request');
  }

  Future<void> deleteRequest(int id) async {
    final response = await http.delete(Uri.parse('${ApiService.baseUrl}/requests/$id'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to delete request');
  }
}