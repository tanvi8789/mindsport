import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mindsport/main.dart'; // Import your theme

class TimerScreen extends StatefulWidget {
  final String exerciseName;

  const TimerScreen({super.key, required this.exerciseName});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _seconds = 60; // default = 1 minute
  int _initialSeconds = 60; // To calculate progress
  Timer? _timer;
  bool isRunning = false;

  final List<int> timeOptions = [30, 60, 120, 180, 300]; // 30s, 1m, 2m, 3m, 5m

  void setTime(int seconds) {
    if (isRunning) return;
    setState(() {
      _seconds = seconds;
      _initialSeconds = seconds;
    });
  }

  void startTimer() {
    if (_timer != null) _timer!.cancel();

    setState(() {
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          isRunning = false;
        });
        // Optional: Play a sound here later
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = _initialSeconds;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Helper to format time MM:SS
  String get _timerString {
    int mins = _seconds ~/ 60;
    int secs = _seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
        titleTextStyle: const TextStyle(
          color: MindSportTheme.darkText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
      ),
      body: Stack(
        children: [
          // --- 1. ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. CONTENT ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            child: Column(
              children: [
                // --- TIMER DISPLAY (Circular) ---
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 15,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              MindSportTheme.softGreen.withOpacity(0.5),
                            ),
                          ),
                        ),
                        // Progress Circle
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: _initialSeconds > 0 ? (_seconds / _initialSeconds) : 0,
                            strokeWidth: 15,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MindSportTheme.primaryGreen,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Text
                        Text(
                          _timerString,
                          style: const TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: MindSportTheme.darkText,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- TIME SELECTOR ---
                const Text(
                  "Set Duration",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: timeOptions.map((sec) {
                    final bool isSelected = _seconds == sec && !isRunning;
                    return ChoiceChip(
                      label: Text(
                        sec >= 60 ? "${sec ~/ 60}m" : "${sec}s",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!isRunning) setTime(sec);
                      },
                      selectedColor: MindSportTheme.primaryGreen,
                      backgroundColor: Colors.white.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 50),

                // --- CONTROLS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Start/Pause Button
                    ElevatedButton(
                      onPressed: isRunning ? pauseTimer : startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MindSportTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        children: [
                          Icon(isRunning ? Icons.pause : Icons.play_arrow),
                          const SizedBox(width: 8),
                          Text(
                            isRunning ? "Pause" : "Start",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Reset Button (Outlined style)
                    OutlinedButton(
                      onPressed: resetTimer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the background painter
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double blurSigma = 45.0;
    final paint1 = Paint()..color = MindSportTheme.softPeach.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    final paint2 = Paint()..color = MindSportTheme.softLavender.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    final paint3 = Paint()..color = MindSportTheme.softGreen.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}