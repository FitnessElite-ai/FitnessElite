enum MessageSender { ai, user }

/// Model representing a single chat message in AI Coach conversation.
class ConversationMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? quickReplies;

  const ConversationMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.quickReplies,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'quickReplies': quickReplies,
    };
  }

  factory ConversationMessage.fromMap(Map<String, dynamic> map) {
    return ConversationMessage(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      sender:
          map['sender'] == 'user' ? MessageSender.user : MessageSender.ai,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      quickReplies: (map['quickReplies'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
