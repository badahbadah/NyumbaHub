import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/hostel.dart';
import 'api_service.dart';

class HostelService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<List<Hostel>> fetchHostels({String? status, int? institutionId, String? search}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (institutionId != null) queryParams['institution_id'] = institutionId.toString();
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final uri = Uri.parse('${ApiService.baseUrl}/hostels').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load hostels');
    final List hostelsJson = data['hostels'];
    return hostelsJson.map((json) => Hostel.fromJson(json)).toList();
  }

  Future<List<Hostel>> fetchMyHostels() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/hostels/mine'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load your hostels');
    final List hostelsJson = data['hostels'];
    return hostelsJson.map((json) => Hostel.fromJson(json)).toList();
  }

  Future<Hostel> createHostel({
    required String name, String? description, int? institutionId, double? latitude, double? longitude,
    required bool hasWaterBackup, required bool hasElectricityBackup, required bool hasSecurity, required bool hasWifi, required bool hasStudyArea,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/hostels'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name, 'description': description, 'institution_id': institutionId, 'latitude': latitude, 'longitude': longitude,
        'has_water_backup': hasWaterBackup, 'has_electricity_backup': hasElectricityBackup,
        'has_security': hasSecurity, 'has_wifi': hasWifi, 'has_study_area': hasStudyArea,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to create hostel');
    return Hostel.fromJson(data['hostel']);
  }

  Future<Hostel> updateHostel({
    required int hostelId, String? name, String? description, int? institutionId,
    bool? hasWaterBackup, bool? hasElectricityBackup, bool? hasSecurity, bool? hasWifi, bool? hasStudyArea,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiService.baseUrl}/hostels/$hostelId'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': ?name,
        'description': ?description,
        'institution_id': ?institutionId,
        'has_water_backup': ?hasWaterBackup,
        'has_electricity_backup': ?hasElectricityBackup,
        'has_security': ?hasSecurity,
        'has_wifi': ?hasWifi,
        'has_study_area': ?hasStudyArea,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to update hostel');
    return Hostel.fromJson(data['hostel']);
  }

  Future<void> markFull(int hostelId) async {
    final response = await http.patch(Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/full'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to update hostel');
  }

  Future<void> markActive(int hostelId) async {
  final response = await http.patch(Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/active'), headers: await _authHeaders());
  final data = jsonDecode(response.body);
  if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to update hostel');
}
}