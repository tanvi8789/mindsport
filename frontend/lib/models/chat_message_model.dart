class ChatMessage {
  final String id;
  final String messageId;
  final String sessionId;
  final String userId;
  final String content;
  final String role; // 'user' or 'assistant'
  final DateTime timestamp;
  final int? tokens;

  ChatMessage({
    required this.id,
    required this.messageId,
    required this.sessionId,
    required this.userId,
    required this.content,
    required this.role,
    required this.timestamp,
    this.tokens,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      messageId: json['message_id'] ?? '',
      sessionId: json['session_id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      role: json['role'] ?? 'user',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      tokens: json['tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_id': messageId,
      'session_id': sessionId,
      'user_id': userId,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'tokens': tokens,
    };
  }

  // Helper getter for UI compatibility
  bool get isUser => role == 'user';
}