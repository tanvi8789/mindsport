import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/chat_provider.dart';
import '../services/voice_service.dart';
import '../models/chat_message_model.dart';
import '../main.dart';
import 'chat_session_screen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceService _voiceService = VoiceService();
  bool _isInitialized = false;
  bool _isListening = false;
  String _partialText = '';
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _initializeVoice();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await Provider.of<ChatProvider>(context, listen: false).initialize();
    _isInitialized = true;
    if (mounted) setState(() {});
  }

  Future<void> _initializeVoice() async {
    bool hasPermission = await _voiceService.initialize();
    if (!hasPermission) {
      // Could show a snackbar or dialog about permission
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Speech recognition permission is required for voice input.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }
    }
  }

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(_textController.text);
    _textController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _startListening() async {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _partialText = '';
      _soundLevel = 0.0;
    });

    await _voiceService.startListening(
      onResult: (text) {
        _textController.text = text;
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });

        // Auto-send if confidence is high? Optional feature
        // if (text.length > 10 && text.endsWith('.')) {
        //   _handleSend();
        // }
      },
      onListeningStarted: () {
        if (mounted) {
          setState(() {
            _isListening = true;
          });
        }
      },
      onListeningStopped: () {
        if (mounted) {
          setState(() {
            _isListening = false;
            _soundLevel = 0.0;
          });
        }
      },
    );
  }

  void _stopListening() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initializing chat...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, chatProvider),
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Chat content
          Column(
            children: [
              // Message List
              Expanded(
                child: _buildMessageList(chatProvider),
              ),

              // Input Area
              _buildInputArea(),
            ],
          ),

          // Voice listening overlay
          if (_isListening) _buildVoiceOverlay(),
        ],
      ),
    );
  }

  Widget _buildVoiceOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated microphone with sound level visualization
          Stack(
            alignment: Alignment.center,
            children: [
              // Sound level circles
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 100 + (_soundLevel * 50),
                height: 100 + (_soundLevel * 50),
                decoration: BoxDecoration(
                  color: MindSportTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      MindSportTheme.primaryGreen.withOpacity(0.9),
                      MindSportTheme.primaryGreen.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MindSportTheme.primaryGreen.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Listening text
          Text(
            'Listening...',
            style: TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Speak clearly into the microphone',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'Nunito',
            ),
          ),

          const SizedBox(height: 30),

          // Cancel button
          ElevatedButton.icon(
            onPressed: _stopListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            icon: const Icon(Icons.close, size: 20),
            label: const Text(
              'Stop Listening',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ChatProvider chatProvider) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wellness Companion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          if (chatProvider.currentSessionName != null)
            Text(
              chatProvider.currentSessionName!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
                fontFamily: 'Nunito',
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: MindSportTheme.darkText),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Voice status indicator in app bar when listening
        if (_isListening)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MindSportTheme.primaryGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                size: 18,
                color: MindSportTheme.primaryGreen,
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.history, color: MindSportTheme.darkText),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatSessionScreen(),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: MindSportTheme.darkText),
          onSelected: (value) {
            if (value == 'new') {
              chatProvider.startNewChat();
            } else if (value == 'sessions') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatSessionScreen(),
                ),
              );
            } else if (value == 'clear') {
              _textController.clear();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'new',
              child: const Row(
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('New Chat'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sessions',
              child: const Row(
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('All Sessions'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'clear',
              child: const Row(
                children: [
                  Icon(Icons.clear_all, size: 20),
                  SizedBox(width: 8),
                  Text('Clear Input'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return CustomPaint(
      painter: _BackgroundPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    if (chatProvider.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Start a conversation about your wellness journey\nor tap the microphone to speak',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Voice prompt
              if (!_isListening)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MindSportTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mic,
                        color: MindSportTheme.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Try voice input',
                        style: TextStyle(
                          color: MindSportTheme.primaryGreen,
                          fontSize: 14,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (chatProvider.isTyping && index == chatProvider.messages.length) {
          return const _TypingIndicator();
        }

        final msg = chatProvider.messages[index];
        return _ChatBubble(message: msg);
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Microphone Button with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isListening ? 50 : 44,
              height: _isListening ? 50 : 44,
              decoration: BoxDecoration(
                gradient: _isListening
                    ? LinearGradient(
                  colors: [
                    MindSportTheme.primaryGreen.withOpacity(0.9),
                    Colors.green.shade400,
                  ],
                )
                    : null,
                color: _isListening ? null : Colors.transparent,
                shape: BoxShape.circle,
                border: _isListening
                    ? null
                    : Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: _toggleListening,
                icon: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: _isListening ? Colors.white : Colors.grey.shade600,
                  size: _isListening ? 24 : 20,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Text Input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F0EC),
                  borderRadius: BorderRadius.circular(25),
                  border: _isListening
                      ? Border.all(
                    color: MindSportTheme.primaryGreen.withOpacity(0.5),
                    width: 2,
                  )
                      : null,
                ),
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 16,
                    color: MindSportTheme.darkText,
                    fontFamily: 'Nunito',
                  ),
                  decoration: InputDecoration(
                    hintText: _isListening ? 'Listening...' : 'Type a message...',
                    hintStyle: TextStyle(
                      color: _isListening
                          ? MindSportTheme.primaryGreen
                          : Colors.grey.shade500,
                      fontFamily: 'Nunito',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _isListening
                        ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            MindSportTheme.primaryGreen,
                          ),
                        ),
                      ),
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    // Update send button state
                    if (mounted) setState(() {});
                  },
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Send Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _textController.text.trim().isEmpty ? 44 : 48,
              height: _textController.text.trim().isEmpty ? 44 : 48,
              decoration: BoxDecoration(
                gradient: _textController.text.trim().isEmpty
                    ? null
                    : LinearGradient(
                  colors: [
                    MindSportTheme.primaryGreen,
                    Colors.green.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                color: _textController.text.trim().isEmpty
                    ? Colors.grey.shade300
                    : null,
                shape: BoxShape.circle,
                boxShadow: _textController.text.trim().isEmpty
                    ? null
                    : [
                  BoxShadow(
                    color: MindSportTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed:
                _textController.text.trim().isEmpty ? null : _handleSend,
                icon: Icon(
                  Icons.send,
                  color: _textController.text.trim().isEmpty
                      ? Colors.grey.shade500
                      : Colors.white,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET: Chat Bubble ---
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final color = isUser
        ? MindSportTheme.primaryGreen
        : Colors.white.withOpacity(0.92);

    final textColor = isUser ? Colors.white : MindSportTheme.darkText;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Voice message indicator for user messages
          if (isUser && message.content.length < 100)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Voice',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    height: 1.4,
                  ),
                ),
                if (message.tokens != null && !isUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Tokens used: ${message.tokens}',
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUser)
                  Icon(
                    Icons.person,
                    size: 10,
                    color: Colors.grey.shade500,
                  ),
                if (isUser) const SizedBox(width: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
        timestamp.year, timestamp.month, timestamp.day);

    if (today == messageDate) {
      return 'Today ${_formatHour(timestamp)}';
    } else if (today.subtract(const Duration(days: 1)) == messageDate) {
      return 'Yesterday ${_formatHour(timestamp)}';
    } else {
      return '${_formatDate(timestamp)} ${_formatHour(timestamp)}';
    }
  }

  String _formatHour(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

// --- WIDGET: Typing Indicator ---
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 6),
                _buildTypingDot(1),
                const SizedBox(width: 6),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final animationDelay = index * 200;
        final animatedValue = (value * 1000 + animationDelay) % 1000 / 1000;

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: MindSportTheme.primaryGreen.withOpacity(
              0.3 + (animatedValue * 0.7),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// --- Background Painter ---
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double blurSigma = 45.0;

    final paint1 = Paint()
      ..color = MindSportTheme.softPeach.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    final paint2 = Paint()
      ..color = MindSportTheme.softLavender.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    final paint3 = Paint()
      ..color = MindSportTheme.softGreen.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}