class Conversation {
  final int id;
  final int initiatorId;
  final int recipientId;
  final String? relatedType;
  final int? relatedId;
  final bool hasUnread;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.initiatorId,
    required this.recipientId,
    this.relatedType,
    this.relatedId,
    required this.hasUnread,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      initiatorId: json['initiator_id'],
      recipientId: json['recipient_id'],
      relatedType: json['related_type'],
      relatedId: json['related_id'],
      hasUnread: json['has_unread'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  int otherUserId(int myId) => initiatorId == myId ? recipientId : initiatorId;
}