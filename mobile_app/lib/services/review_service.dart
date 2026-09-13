import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchReviews(int hostelId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/reviews'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load reviews');
    }
    final List reviewsJson = data['reviews'];
    return {
      'averages': ReviewAverages.fromJson(data['averages']),
      'reviews': reviewsJson.map((json) => Review.fromJson(json)).toList(),
    };
  }

  Future<void> submitReview({
    required int hostelId,
    required int waterRating,
    required int electricityRating,
    required int safetyRating,
    required int responsivenessRating,
    String? comment,
  }) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/reviews'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'water_rating': waterRating,
        'electricity_rating': electricityRating,
        'safety_rating': safetyRating,
        'responsiveness_rating': responsivenessRating,
        'comment': comment,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Failed to submit review');
    }
  }
}