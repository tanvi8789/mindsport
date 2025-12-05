import 'package:flutter/material.dart';
import 'package:mindsport/services/mood_provider.dart';
import 'package:mindsport/services/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/screens/sidebar.dart';
import 'dart:convert';
import 'dart:ui'; // Required for BackdropFilter (Glassmorphism)
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Ensure you have this in pubspec.yaml for date formatting
import 'package:mindsport/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // --- NEW: SLIDER STATE ---
  double _sleepValue = 5.0;
  double _physicalValue = 5.0;

  // --- NEW: QUOTE LOGIC ---
  // A curated list of athlete-focused quotes
  final List<String> _quotes = [
    "The only way to prove that you’re a good sport is to lose.",
    "It is not the mountain we conquer, but ourselves.",
    "Pain is temporary. Quitting lasts forever.",
    "Run when you can, walk if you have to, crawl if you must; just never give up.",
    "You miss 100% of the shots you don't take.",
    "Champions keep playing until they get it right.",
    "Hard work beats talent when talent doesn't work hard.",
    "Success is where preparation and opportunity meet.",
    "Believe you can and you're halfway there.",
    "Focus on the process, not the outcome."
  ];

  String _getDailyQuote() {
    // Pick a quote based on the day of the year so it changes every 24h
    final now = DateTime.now();
    final dayOfYear = int.parse(DateFormat("D").format(now));
    return _quotes[dayOfYear % _quotes.length];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

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
    // ... (Your existing submit logic - Unchanged) ...
    // Just copy the logic from the previous file here for brevity
    // Or I can re-paste it if you need it.
    // For this update, the logic inside _submitMood doesn't change.

    // --- TEMPORARY COPY OF LOGIC ---
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final moodKeyword = moodProvider.todaysMoodKeyword;
    final userId = userProvider.user?.id;

    if (moodKeyword == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a mood first!')));
      return;
    }
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found. Please restart.')));
      return;
    }

    const String apiUrl = 'https://mindsport-backend.onrender.com/api/moods';
    final Map<String, dynamic> body = {
      'mood': moodKeyword, 'reason': '', 'userId': userId,
      'sleep': _sleepValue.round(), 'physical': _physicalValue.round()
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Saving daily stats...'), backgroundColor: MindSportTheme.softLavender, duration: const Duration(seconds: 1)));

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Stats saved successfully!'), backgroundColor: MindSportTheme.primaryGreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.statusCode}'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection Error'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Athlete';
    final todayDate = DateFormat.yMMMMd().format(DateTime.now()); // e.g. "July 12, 2025"

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
        actions: [
          // Profile Icon Shortcut
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: MindSportTheme.primaryGreen.withOpacity(0.2),
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: MindSportTheme.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
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
                  // --- 1. PROFESSIONAL HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todayDate.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getGreeting()},',
                          style: const TextStyle(fontSize: 24, color: MindSportTheme.darkText),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: MindSportTheme.darkText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 2. DAILY QUOTE (Glass Card) ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.0,
                    child: _buildGlassCard(
                      child: Column(
                        children: [
                          const Icon(Icons.format_quote, color: MindSportTheme.primaryGreen, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            _getDailyQuote(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: MindSportTheme.darkText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Daily Check-in",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MindSportTheme.darkText),
                  ),
                  const SizedBox(height: 12),

                  // --- 3. MOOD & STATS ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.1,
                    child: _buildMoodCard(context, moodProvider),
                  ),
                  const SizedBox(height: 16),

                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.2,
                    child: _buildStatsCard(),
                  ),
                  const SizedBox(height: 16),

                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.3,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitMood(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MindSportTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Log Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Quick Access",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MindSportTheme.darkText),
                  ),
                  const SizedBox(height: 12),

                  // --- 4. DASHBOARD GRID (New Layout) ---
                  // Moving History and Reminders side-by-side
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.4,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGridCard(
                            context: context,
                            title: "Mood\nCalendar",
                            icon: Icons.calendar_month,
                            color: MindSportTheme.softGreen,
                            routeName: '/history',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGridCard(
                            context: context,
                            title: "My\nReminders",
                            icon: Icons.alarm,
                            color: MindSportTheme.softLavender,
                            routeName: '/reminders',
                          ),
                        ),
                      ],
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

  // --- NEW: GLASS CARD HELPER ---
  Widget _buildGlassCard({required Widget child, Color color = Colors.white}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The blur effect
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.6), // Translucent
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  // --- NEW: GRID CARD HELPER ---
  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String routeName,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 130, // Fixed height for square-ish look
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
              child: Icon(icon, color: MindSportTheme.darkText, size: 24),
            ),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MindSportTheme.darkText,
                  height: 1.2
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSED WIDGETS ---
  // (Stats Card and Mood Card same as before, just wrapped in Glass styling implicitly or kept clean)

  Widget _buildStatsCard() {
    return _buildGlassCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recovery & Load", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 16),
          _buildSliderRow("Sleep", _sleepValue, MindSportTheme.primaryGreen, (v) => setState(() => _sleepValue = v)),
          const SizedBox(height: 12),
          _buildSliderRow("Strain", _physicalValue, Colors.orangeAccent, (v) => setState(() => _physicalValue = v)),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text("${value.round()}/10", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value, min: 1, max: 10, divisions: 9,
            activeColor: color, inactiveColor: color.withOpacity(0.2),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCard(BuildContext context, MoodProvider moodProvider) {
    final Map<String, String> moodMap = {
      '😄': 'excited', '😊': 'happy', '😐': 'neutral', '😢': 'sad', '😠': 'angry',
    };
    final emojiOptions = moodMap.keys.toList();

    return _buildGlassCard(
      color: MindSportTheme.softGreen,
      child: Column(
        children: [
          const Text("How are you feeling?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MindSportTheme.darkText)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: emojiOptions.map((emoji) {
              final isSelected = moodProvider.todaysMoodKeyword == moodMap[emoji];
              return GestureDetector(
                onTap: () => moodProvider.selectMood(moodMap[emoji]!),
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isSelected ? [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 15)] : null,
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 34)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Background Painter (Same as before) ---
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