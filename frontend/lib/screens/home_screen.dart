import 'package:flutter/material.dart';
import 'package:mindsport/services/mood_provider.dart';
import 'package:mindsport/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/screens/sidebar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mindsport/main.dart'; // Import theme

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // --- NEW: ATHLETE STATS STATE ---
  double _sleepValue = 5.0; // Default middle value
  double _physicalValue = 5.0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.fetchUserData();
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitMood(BuildContext context) async {
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final moodKeyword = moodProvider.todaysMoodKeyword;
    final userId = userProvider.user?.id;

    if (moodKeyword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first!')),
      );
      return;
    }
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please restart.')),
      );
      return;
    }

    const String apiUrl = 'https://mindsport-backend.onrender.com/api/moods';

    // --- UPDATED: SENDING ATHLETE STATS ---
    final Map<String, dynamic> body = {
      'mood': moodKeyword,
      'reason': '',
      'userId': userId,
      'sleep': _sleepValue.round(),    // Send as integer (1-10)
      'physical': _physicalValue.round() // Send as integer (1-10)
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saving daily check-in...'),
        backgroundColor: MindSportTheme.softLavender,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Daily stats saved successfully!'),
              backgroundColor: MindSportTheme.primaryGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection Error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Athlete';

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
      ),
      body: Stack(
        children: [
          CustomPaint(painter: _BackgroundPainter(), size: Size.infinite),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '🌱 Hello, $userName!',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: MindSportTheme.darkText),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 1. Mood Card
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.0,
                    child: _buildMoodCard(context, moodProvider),
                  ),
                  const SizedBox(height: 16),

                  // --- 2. NEW: PERFORMANCE LOG ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.1,
                    child: _buildStatsCard(),
                  ),
                  const SizedBox(height: 16),

                  // 3. Save Button
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.2,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitMood(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MindSportTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Save Daily Check-in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Navigation Cards
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.25,
                    child: _buildNavigationCard(
                      context: context,
                      title: 'View Mood Calendar',
                      color: MindSportTheme.softGreen,
                      icon: Icons.calendar_month,
                      routeName: '/history',
                    ),
                  ),
                  const SizedBox(height: 24),

                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.3,
                    child: _buildQuoteCard(),
                  ),
                  const SizedBox(height: 24),

                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.4,
                    child: _buildNavigationCard(
                      context: context,
                      title: 'Check your reminders',
                      color: MindSportTheme.softLavender,
                      icon: Icons.alarm,
                      routeName: '/reminders',
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: MindSportTheme.primaryGreen,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // --- NEW WIDGET: SLIDERS ---
  Widget _buildStatsCard() {
    return Card(
      color: Colors.white.withOpacity(0.85), // Clean white background for data
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recovery & Load",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MindSportTheme.darkText),
            ),
            const SizedBox(height: 20),

            // Sleep Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sleep Quality", style: TextStyle(fontWeight: FontWeight.w600)),
                Text("${_sleepValue.round()}/10", style: const TextStyle(fontWeight: FontWeight.bold, color: MindSportTheme.primaryGreen)),
              ],
            ),
            Slider(
              value: _sleepValue,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: MindSportTheme.primaryGreen,
              inactiveColor: MindSportTheme.softGreen,
              onChanged: (val) => setState(() => _sleepValue = val),
            ),

            const SizedBox(height: 10),

            // Physical Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Physical Strain", style: TextStyle(fontWeight: FontWeight.w600)),
                Text("${_physicalValue.round()}/10", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
              ],
            ),
            Slider(
              value: _physicalValue,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: Colors.orangeAccent,
              inactiveColor: Colors.orange.withOpacity(0.3),
              onChanged: (val) => setState(() => _physicalValue = val),
            ),
          ],
        ),
      ),
    );
  }

  // --- EXISTING WIDGETS ---
  Widget _buildMoodCard(BuildContext context, MoodProvider moodProvider) {
    final Map<String, String> moodMap = {
      '😄': 'excited', '😊': 'happy', '😐': 'neutral', '😢': 'sad', '😠': 'angry',
    };
    final emojiOptions = moodMap.keys.toList();

    return Card(
      color: MindSportTheme.softGreen.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Nunito', color: MindSportTheme.darkText),
            ),
            const SizedBox(height: 20),
            Row(
              children: emojiOptions.map((emoji) {
                final isSelected = moodProvider.todaysMoodKeyword == moodMap[emoji];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final keyword = moodMap[emoji];
                      if (keyword != null) moodProvider.selectMood(keyword);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Card(
      color: MindSportTheme.softPeach.withOpacity(0.85),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Text(
          ' 💫 "The sky has no limits, neither should you" 💫',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: MindSportTheme.darkText, fontFamily: 'Nunito', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({required BuildContext context, required String title, required Color color, required IconData icon, required String routeName}) {
    return Card(
      color: color.withOpacity(0.85),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: MindSportTheme.darkText, size: 28),
                  const SizedBox(width: 16),
                  Text(title, style: const TextStyle(fontSize: 18, color: MindSportTheme.darkText, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: MindSportTheme.darkText),
            ],
          ),
        ),
      ),
    );
  }
}

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