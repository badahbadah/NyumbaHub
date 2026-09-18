import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/room.dart';
import 'api_service.dart';

class RoomService {
  final storage = const FlutterSecureStorage();

  Future<List<Room>> fetchRooms(int hostelId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/rooms'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load rooms');
    }
    final List roomsJson = data['rooms'];
    return roomsJson.map((json) => Room.fromJson(json)).toList();
  }

  Future<Room> createRoom({
    required int hostelId,
    required String roomType,
    required double priceAmount,
    required String pricePeriod,
    required int totalBeds,
    required bool isSelfContained,
  }) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/rooms'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'room_type': roomType,
        'price_amount': priceAmount,
        'price_period': pricePeriod,
        'total_beds': totalBeds,
        'is_self_contained': isSelfContained,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Failed to add room');
    }
    return Room.fromJson(data['room']);
  }

  Future<void> updateAvailableBeds({required int hostelId, required int roomId, required int availableBeds}) async {
  final token = await storage.read(key: 'auth_token');
  final response = await http.patch(
    Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/rooms/$roomId/beds'),
    headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    body: jsonEncode({'available_beds': availableBeds}),
  );
  final data = jsonDecode(response.body);
  if (response.statusCode != 200) {
    throw Exception(data['error'] ?? 'Failed to update room availability');
  }
}
}