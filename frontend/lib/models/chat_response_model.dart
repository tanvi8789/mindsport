import 'session_model.dart';
import 'chat_message_model.dart';

class ChatResponse {
  final String sessionId;
  final String response;
  final String userId;
  final int tokensUsed;
  final int historicalContextUsed;
  final Map<String, dynamic> vectorStoreStats;

  ChatResponse({
    required this.sessionId,
    required this.response,
    required this.userId,
    required this.tokensUsed,
    required this.historicalContextUsed,
    required this.vectorStoreStats,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      sessionId: json['session_id'] ?? '',
      response: json['response'] ?? '',
      userId: json['user_id'] ?? '',
      tokensUsed: json['tokens_used'] ?? 0,
      historicalContextUsed: json['historical_context_used'] ?? 0,
      vectorStoreStats: Map<String, dynamic>.from(json['vector_store_stats'] ?? {}),
    );
  }
}

class SessionListResponse {
  final List<ChatSession> sessions;

  SessionListResponse({required this.sessions});

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    final sessionsList = json['sessions'] as List? ?? [];
    final sessions = sessionsList
        .map((session) => ChatSession.fromJson(session))
        .toList();
    return SessionListResponse(sessions: sessions);
  }
}

class MessageListResponse {
  final List<ChatMessage> messages;

  MessageListResponse({required this.messages});

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final messagesList = json['messages'] as List? ?? [];
    final messages = messagesList
        .map((message) => ChatMessage.fromJson(message))
        .toList();
    return MessageListResponse(messages: messages);
  }
}