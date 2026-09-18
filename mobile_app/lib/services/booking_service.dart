import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> createBooking({required int roomId, required double depositAmount}) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/bookings'),
      headers: await _authHeaders(),
      body: jsonEncode({'room_id': roomId, 'deposit_amount': depositAmount}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to create booking');
    return data['booking'];
  }

  Future<Map<String, dynamic>> payForBooking({required int bookingId, required String phoneNumber, required String provider}) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/bookings/$bookingId/pay'),
      headers: await _authHeaders(),
      body: jsonEncode({'phone_number': phoneNumber, 'provider': provider}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 202) throw Exception(data['error'] ?? 'Failed to initiate payment');
    return data['transaction'];
  }

  Future<void> simulateWebhook({required String providerReference, required String status}) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/webhooks/payments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'provider_reference': providerReference, 'status': status}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to simulate payment result');
  }

  Future<List<Booking>> fetchMyBookings() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/bookings/mine'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load bookings');
    final List bookingsJson = data['bookings'];
    return bookingsJson.map((json) => Booking.fromJson(json)).toList();
  }

  Future<List<Booking>> fetchBookingsForHostel(int hostelId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/hostels/$hostelId/bookings'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load bookings');
    final List bookingsJson = data['bookings'];
    return bookingsJson.map((json) => Booking.fromJson(json)).toList();
  }

  Future<void> deleteBooking(int bookingId) async {
    final response = await http.delete(Uri.parse('${ApiService.baseUrl}/bookings/$bookingId'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to delete booking');
  }

  Future<void> approveBooking(int bookingId) async {
    final response = await http.patch(Uri.parse('${ApiService.baseUrl}/bookings/$bookingId/approve'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to approve booking');
  }

  Future<void> rejectBooking(int bookingId) async {
    final response = await http.patch(Uri.parse('${ApiService.baseUrl}/bookings/$bookingId/reject'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to reject booking');
  }

  Future<int> fetchPendingCount() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/bookings/pending-count'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load pending count');
    return data['pending_count'] ?? 0;
  }
}