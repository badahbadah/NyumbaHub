import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/property_media.dart';
import 'api_service.dart';

class PropertyMediaService {
  final storage = const FlutterSecureStorage();

  Future<List<PropertyMedia>> fetchMedia(int propertyId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/properties/$propertyId/media'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load photos');
    final List mediaJson = data['media'];
    return mediaJson.map((json) => PropertyMedia.fromJson(json)).toList();
  }

  Future<void> uploadPhotos(int propertyId, List<File> photos) async {
    final token = await storage.read(key: 'auth_token');
    final uri = Uri.parse('${ApiService.baseUrl}/properties/$propertyId/media');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    for (final photo in photos) {
      final mimeType = lookupMimeType(photo.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath('photos', photo.path, contentType: MediaType.parse(mimeType)));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to upload photos');
  }

  Future<void> deletePhoto(int propertyId, int mediaId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/properties/$propertyId/media/$mediaId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to delete photo');
  }
}