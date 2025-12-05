import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_response_model.dart';
import '../models/session_model.dart';
import '../models/chat_message_model.dart';

class ChatService {
  // ⚠️ IMPORTANT: Update this to match your Flask server
  // For local development with emulator: 'http://10.0.2.2:5000/api'
  // For local development with physical device: 'http://YOUR_LOCAL_IP:5000/api'
  // For production: 'https://your-domain.com/api'
  final String _baseUrl = 'http://10.223.43.94:5000/api'; // Example for Android emulator

  final _storage = const FlutterSecureStorage();
  final String _sessionKey = 'current_session_id';
  final String _userIdKey = 'user_id';

  /// Helper method to handle HTTP requests
  Future<Map<String, dynamic>> _makeRequest(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};

    print('🌐 $method Request to: $url');
    if (body != null) print('📦 Request Body: $body');

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Send a message - handles both new and existing sessions
  Future<ChatResponse> sendMessage(String message) async {
    final userId = await _storage.read(key: _userIdKey);
    if (userId == null) throw Exception('User not logged in');

    // Check if we have an active session
    final currentSessionId = await _storage.read(key: _sessionKey);

    print('💬 Sending message: $message');
    print('👤 User ID: $userId');
    print('📁 Session ID: $currentSessionId');

    // Build request body
    Map<String, dynamic> requestBody = {
      'user_id': userId,
      'message': message,
    };

    // Add session_id only if we have one
    if (currentSessionId != null) {
      requestBody['session_id'] = currentSessionId;
    }

    final response = await _makeRequest('POST', '/chat', body: requestBody);

    // Check for error in response
    if (response['error'] != null) {
      throw Exception(response['error'] ?? 'Failed to send message');
    }

    final chatResponse = ChatResponse.fromJson(response);

    // Save the session ID if this is a new session
    if (currentSessionId == null || currentSessionId != chatResponse.sessionId) {
      await _storage.write(key: _sessionKey, value: chatResponse.sessionId);
      print('✅ Saved new session ID: ${chatResponse.sessionId}');
    }

    return chatResponse;
  }

  /// Get all sessions for the current user
  Future<List<ChatSession>> getSessions() async {
    final userId = await _storage.read(key: _userIdKey);
    if (userId == null) throw Exception('User not logged in');

    print('📋 Fetching sessions for user: $userId');

    final response = await _makeRequest('GET', '/sessions/$userId');

    if (response['error'] != null) {
      throw Exception(response['error'] ?? 'Failed to fetch sessions');
    }

    // The Flask endpoint returns {"sessions": [...]}
    final sessions = response['sessions'] as List<dynamic>;
    print('✅ Found ${sessions.length} sessions');

    return sessions.map((sessionJson) => ChatSession.fromJson(sessionJson)).toList();
  }

  /// Get messages for a specific session
  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    print('📨 Fetching messages for session: $sessionId');

    final response = await _makeRequest('GET', '/messages/$sessionId');

    if (response['error'] != null) {
      throw Exception(response['error'] ?? 'Failed to fetch messages');
    }

    // The Flask endpoint returns {"messages": [...]}
    final messages = response['messages'] as List<dynamic>;
    print('✅ Found ${messages.length} messages');

    return messages.map((messageJson) => ChatMessage.fromJson(messageJson)).toList();
  }

  /// Set current session ID
  Future<void> setCurrentSession(String sessionId) async {
    await _storage.write(key: _sessionKey, value: sessionId);
    print('📝 Set current session to: $sessionId');
  }

  /// Get current session ID
  Future<String?> getCurrentSession() async {
    final sessionId = await _storage.read(key: _sessionKey);
    print('📖 Current session: $sessionId');
    return sessionId;
  }

  /// Clear current session (for starting fresh)
  Future<void> clearCurrentSession() async {
    await _storage.delete(key: _sessionKey);
    print('🗑️ Cleared current session');
  }

  /// Start a completely new chat
  Future<void> startNewChat() async {
    await clearCurrentSession();
    print('✨ Ready for new chat session');
  }

  /// Delete a session (Note: Your Flask backend doesn't have this endpoint yet)
  Future<bool> deleteSession(String sessionId) async {
    try {
      print('🗑️ Deleting session: $sessionId');
      // ⚠️ You need to add this endpoint to your Flask backend
      // Example: @app.route('/api/sessions/<session_id>', methods=['DELETE'])
      final response = await _makeRequest('DELETE', '/sessions/$sessionId');
      return response['error'] == null;
    } catch (e) {
      print('❌ Failed to delete session: $e');
      return false;
    }
  }

  /// Update session name (Note: Your Flask backend doesn't have this endpoint yet)
  Future<bool> updateSessionName(String sessionId, String name) async {
    try {
      print('✏️ Renaming session $sessionId to: $name');
      // ⚠️ You need to add this endpoint to your Flask backend
      // Example: @app.route('/api/sessions/<session_id>', methods=['PUT'])
      final response = await _makeRequest('PUT', '/sessions/$sessionId', body: {
        'session_name': name,
      });
      return response['error'] == null;
    } catch (e) {
      print('❌ Failed to rename session: $e');
      return false;
    }
  }

  /// Debug endpoint to check vector store contents
  Future<Map<String, dynamic>> debugVectorStore(String userId) async {
    try {
      print('🔍 Debugging vector store for user: $userId');
      final response = await _makeRequest('GET', '/debug/vector-store?user_id=$userId');
      return response;
    } catch (e) {
      print('❌ Failed to debug vector store: $e');
      throw e;
    }
  }
}