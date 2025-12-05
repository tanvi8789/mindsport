import 'package:flutter/material.dart';
import 'chat_service.dart';
import '../models/chat_message_model.dart';
import '../models/session_model.dart';
import '../models/chat_response_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Current session data
  String? _currentSessionId;
  String? _currentSessionName;

  // Messages for current session
  final List<ChatMessage> _messages = [];

  // All user sessions
  List<ChatSession> _sessions = [];

  // Loading states
  bool _isTyping = false;
  bool _isLoadingSessions = false;
  bool _isLoadingMessages = false;

  // Error state
  String? _error;

  // Getters
  String? get currentSessionId => _currentSessionId;
  String? get currentSessionName => _currentSessionName;
  List<ChatMessage> get messages => _messages;
  List<ChatSession> get sessions => _sessions;
  bool get isTyping => _isTyping;
  bool get isLoadingSessions => _isLoadingSessions;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get error => _error;

  // Initialize provider - load current session and sessions list
  Future<void> initialize() async {
    await _loadCurrentSession();
    await _loadSessions();
  }

  // Load current session from storage
  Future<void> _loadCurrentSession() async {
    _currentSessionId = await _chatService.getCurrentSession();
    if (_currentSessionId != null) {
      await _loadSessionMessages(_currentSessionId!);
    }
  }

  // Load all sessions for user
  Future<void> _loadSessions() async {
    _isLoadingSessions = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _chatService.getSessions();
    } catch (e) {
      _error = 'Failed to load sessions: ${e.toString()}';
      print('❌ Error loading sessions: $_error');
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  // Load messages for a specific session
  Future<void> _loadSessionMessages(String sessionId) async {
    _isLoadingMessages = true;
    _error = null;
    notifyListeners();

    try {
      final sessionMessages = await _chatService.getSessionMessages(sessionId);
      _messages.clear();
      _messages.addAll(sessionMessages);

      // Update session name from sessions list
      _updateSessionName(sessionId);

    } catch (e) {
      _error = 'Failed to load messages: ${e.toString()}';
      print('❌ Error loading messages: $_error');
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Helper to update session name
  void _updateSessionName(String sessionId) {
    try {
      final session = _sessions.firstWhere(
            (s) => s.sessionId == sessionId,
        orElse: () => ChatSession(
          id: '',
          sessionId: sessionId,
          userId: '',
          sessionName: 'Chat',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _currentSessionName = session.sessionName;
    } catch (e) {
      _currentSessionName = 'Chat';
    }
  }

  // Send a message - FIXED VERSION
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Clear any previous error
    _error = null;

    // Add user message to UI immediately
    final userMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      messageId: 'temp_msg',
      sessionId: _currentSessionId ?? 'new',
      userId: 'current',
      content: text,
      role: 'user',
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      // ✅ FIXED: Call sendMessage without sessionId parameter
      final response = await _chatService.sendMessage(text);

      // Update current session if this was a new session
      if (_currentSessionId == null) {
        _currentSessionId = response.sessionId;
        // Set session name from first message
        _currentSessionName = text.length > 30
            ? '${text.substring(0, 30)}...'
            : text;
      }

      // Add assistant response
      final assistantMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch + 1}',
        messageId: 'temp_assistant_msg',
        sessionId: response.sessionId,
        userId: response.userId,
        content: response.response,
        role: 'assistant',
        timestamp: DateTime.now(),
        tokens: response.tokensUsed,
      );
      _messages.add(assistantMessage);

      // Refresh sessions list
      await _loadSessions();

    } catch (e) {
      _error = e.toString();
      print('❌ Error sending message: $_error');

      // Add error message to chat
      _messages.add(ChatMessage(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        messageId: 'error_msg',
        sessionId: _currentSessionId ?? 'error',
        userId: 'system',
        content: 'Sorry, I encountered an error. Please try again.',
        role: 'assistant',
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // Switch to a different session
  Future<void> switchSession(String sessionId) async {
    await _chatService.setCurrentSession(sessionId);
    _currentSessionId = sessionId;
    _currentSessionName = null;
    _messages.clear();
    await _loadSessionMessages(sessionId);

    // Update session name
    _updateSessionName(sessionId);
  }

  // Start a new chat
  Future<void> startNewChat() async {
    await _chatService.clearCurrentSession();
    _currentSessionId = null;
    _currentSessionName = 'New Chat';
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    final success = await _chatService.deleteSession(sessionId);
    if (success) {
      _sessions.removeWhere((s) => s.sessionId == sessionId);
      if (_currentSessionId == sessionId) {
        await startNewChat();
      }
      notifyListeners();
    }
  }

  // Update session name
  Future<void> updateSessionName(String sessionId, String newName) async {
    final success = await _chatService.updateSessionName(sessionId, newName);
    if (success) {
      final index = _sessions.indexWhere((s) => s.sessionId == sessionId);
      if (index != -1) {
        _sessions[index] = ChatSession(
          id: _sessions[index].id,
          sessionId: sessionId,
          userId: _sessions[index].userId,
          sessionName: newName,
          createdAt: _sessions[index].createdAt,
          updatedAt: DateTime.now(),
        );
      }
      if (_currentSessionId == sessionId) {
        _currentSessionName = newName;
      }
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}