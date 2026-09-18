import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/institution.dart';
import 'api_service.dart';

class InstitutionService {
  Future<List<Institution>> fetchInstitutions() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/institutions'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load institutions');
    }
    final List institutionsJson = data['institutions'];
    return institutionsJson.map((json) => Institution.fromJson(json)).toList();
  }
}