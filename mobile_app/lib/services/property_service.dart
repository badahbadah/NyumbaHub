import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import 'api_service.dart';

class PropertyService {
  Future<List<Property>> fetchProperties({String? city, String? listingType}) async {
    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (listingType != null) queryParams['listing_type'] = listingType;

    final uri = Uri.parse('${ApiService.baseUrl}/properties')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load properties');
    }

    final List propertiesJson = data['properties'];
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }
}