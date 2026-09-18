import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'api_service.dart';

class ConversationService {
  final storage = const FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> startOrSend({
    required int recipientId, String? relatedType, int? relatedId, required String messageText,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/conversations'),
      headers: await _authHeaders(),
      body: jsonEncode({'recipient_id': recipientId, 'related_type': relatedType, 'related_id': relatedId, 'message_text': messageText}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to send message');
    return data;
  }

  Future<List<Conversation>> fetchMyConversations() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/conversations'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load conversations');
    final List convJson = data['conversations'];
    return convJson.map((json) => Conversation.fromJson(json)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(int conversationId) async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/messages'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load messages');
    final List msgJson = data['messages'];
    return msgJson.map((json) => ChatMessage.fromJson(json)).toList();
  }

  Future<ChatMessage> sendReply(int conversationId, String messageText) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/messages'),
      headers: await _authHeaders(),
      body: jsonEncode({'message_text': messageText}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 201) throw Exception(data['error'] ?? 'Failed to send message');
    return ChatMessage.fromJson(data['sentMessage']);
  }

  Future<int> fetchUnreadCount() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/conversations/unread-count'), headers: await _authHeaders());
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) throw Exception(data['error'] ?? 'Failed to load unread count');
    return data['unread_count'] ?? 0;
  }
}