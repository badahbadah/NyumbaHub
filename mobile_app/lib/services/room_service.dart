import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import 'api_service.dart';

class RoomService {
  Future<List<Room>> fetchRooms(int hostelId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/rooms'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to load rooms');
    }
    final List roomsJson = data['rooms'];
    return roomsJson.map((json) => Room.fromJson(json)).toList();
  }
}