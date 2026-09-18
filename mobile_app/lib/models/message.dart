class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String messageText;
  final DateTime sentAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageText,
    required this.sentAt,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      messageText: json['message_text'],
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}