import 'package:flutter/material.dart';
import 'package:mindsport/main.dart'; // Theme
import 'package:mindsport/screens/sidebar.dart';
import 'package:mindsport/screens/timer_screen.dart'; // Import the timer

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        title: const Text('Mental Gym'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
      ),
      body: Stack(
        children: [
          // Background
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Train Your Mind',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MindSportTheme.darkText
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Quick exercises to reset, focus, and recover.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),

                // --- EXERCISE LIST ---

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.1,
                  child: _buildExerciseCard(
                    context,
                    title: "Box Breathing",
                    subtitle: "Calm your nervous system (4-4-4-4)",
                    icon: Icons.air,
                    color: MindSportTheme.softGreen,
                  ),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.2,
                  child: _buildExerciseCard(
                    context,
                    title: "Pre-Game Visualization",
                    subtitle: "Rehearse your success",
                    icon: Icons.visibility,
                    color: MindSportTheme.softLavender,
                  ),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.3,
                  child: _buildExerciseCard(
                    context,
                    title: "Muscle Relaxation",
                    subtitle: "Release physical tension",
                    icon: Icons.accessibility_new,
                    color: MindSportTheme.softPeach,
                  ),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.4,
                  child: _buildExerciseCard(
                    context,
                    title: "Focus Timer",
                    subtitle: "Pure concentration block",
                    icon: Icons.timer,
                    color: Colors.blueGrey.shade100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
      }) {
    return Card(
      color: color.withOpacity(0.85),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          // Navigate to the TimerScreen with the specific exercise name
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimerScreen(exerciseName: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: MindSportTheme.darkText, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MindSportTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, color: MindSportTheme.darkText, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// Reuse helper classes to keep file self-contained if needed,
// or import them if you moved them to a separate widgets file.
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

class _FadeInSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;
  const _FadeInSlide({required this.animation, required this.delay, required this.child});
  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic));
    return AnimatedBuilder(animation: curvedAnimation, builder: (context, child) {
      return Transform.translate(offset: Offset(0, (1.0 - curvedAnimation.value) * 30), child: Opacity(opacity: curvedAnimation.value, child: child));
    }, child: child);
  }
}