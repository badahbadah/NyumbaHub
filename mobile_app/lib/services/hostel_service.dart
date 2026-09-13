import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hostel.dart';
import 'api_service.dart';

class HostelService {
  Future<List<Hostel>> fetchHostels({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('${ApiService.baseUrl}/hostels').replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load hostels');
    }

    final List hostelsJson = data['hostels'];
    return hostelsJson.map((json) => Hostel.fromJson(json)).toList();
  }
}