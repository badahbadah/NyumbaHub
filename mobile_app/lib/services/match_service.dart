import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/property_match.dart';
import 'api_service.dart';

class MatchService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<PropertyMatch> submitMatch({required int requestId, required int propertyId}) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/requests/$requestId/matches'),
      headers: await _authHeaders(),
      body: jsonEncode({'property_id': propertyId}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to submit match');
    return PropertyMatch.fromJson(data['match']);
  }

  Future<List<PropertyMatch>> fetchMatchesForRequest(int requestId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/requests/$requestId/matches'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load offers');
    final List matchesJson = data['matches'];
    return matchesJson.map((json) => PropertyMatch.fromJson(json)).toList();
  }

  Future<List<PropertyMatch>> fetchMyMatches() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/matches/mine'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load your matches');
    final List matchesJson = data['matches'];
    return matchesJson.map((json) => PropertyMatch.fromJson(json)).toList();
  }

  Future<void> updateMatchStatus(int matchId, String status) async {
    final response = await http.patch(
      Uri.parse('${ApiService.baseUrl}/matches/$matchId'),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to update match');
  }

  Future<int> fetchPendingCount() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/matches/pending-count'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load pending count');
    return data['pending_count'] ?? 0;
  }
}