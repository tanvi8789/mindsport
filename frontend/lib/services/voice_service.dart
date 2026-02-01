import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == stt.SpeechToText.doneStatus) {
          _isListening = false;
        }
      },
      onError: (error) {
        print('Speech error: $error');
        _isListening = false;
      },
    );

    return available;
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String text) onResult,
    Function()? onListeningStarted,
    Function()? onListeningStopped,
  }) async {
    if (_isListening) return;

    _lastWords = '';
    _isListening = true;

    if (onListeningStarted != null) onListeningStarted();

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastWords = result.recognizedWords;
          _isListening = false;
          onResult(_lastWords);

          if (onListeningStopped != null) onListeningStopped();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: true,
      localeId: 'en_US', // You can change this based on user preference
      onSoundLevelChange: (level) {
        // Optional: You can use this for visual feedback
      },
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speech.stop();
    _isListening = false;
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (!_isListening) return;

    await _speech.cancel();
    _isListening = false;
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
  }
}