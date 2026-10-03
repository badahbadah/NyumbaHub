import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/property.dart';
import 'api_service.dart';

class PropertyService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<List<Property>> fetchProperties({String? city, String? listingType, String? propertyType}) async {
    final queryParams = <String, String>{};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (listingType != null) queryParams['listing_type'] = listingType;
    if (propertyType != null) queryParams['property_type'] = propertyType;

    final uri = Uri.parse('${ApiService.baseUrl}/properties').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load properties');
    final List propertiesJson = data['properties'];
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  Future<List<Property>> fetchMyProperties() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/properties/mine'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load your listings');
    final List propertiesJson = data['properties'];
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  Future<Property> createProperty({
    required String listingType,
    required String propertyType,
    required String city,
    String? area,
    int? bedrooms,
    int? bathrooms,
    required double priceAmount,
    String? pricePeriod,
    String? description,
    required bool isFenced,
    required bool hasWaterTank,
    required bool isPaved,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/properties'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'listing_type': listingType, 'property_type': propertyType, 'city': city, 'area': area,
        'bedrooms': bedrooms, 'bathrooms': bathrooms, 'price_amount': priceAmount, 'price_period': pricePeriod,
        'description': description, 'is_fenced': isFenced, 'has_water_tank': hasWaterTank, 'is_paved': isPaved,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to create listing');
    return Property.fromJson(data['property']);
  }

  Future<Property> updateProperty(int id, Map<String, dynamic> fields) async {
    final response = await http.patch(
      Uri.parse('${ApiService.baseUrl}/properties/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(fields),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to update listing');
    return Property.fromJson(data['property']);
  }

  Future<void> markTaken(int id) async {
    final response = await http.patch(Uri.parse('${ApiService.baseUrl}/properties/$id/taken'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to update listing');
  }

  Future<void> deleteProperty(int id) async {
    final response = await http.delete(Uri.parse('${ApiService.baseUrl}/properties/$id'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to delete listing');
  }
}