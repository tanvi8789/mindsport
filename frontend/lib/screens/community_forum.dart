import 'package:flutter/material.dart';
import 'package:mindsport/main.dart'; // Import theme
import 'package:mindsport/screens/sidebar.dart';

class CommunityForum extends StatefulWidget {
  const CommunityForum({super.key});

  @override
  State<CommunityForum> createState() => _CommunityForumState();
}

class _CommunityForumState extends State<CommunityForum> with SingleTickerProviderStateMixin {
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
        title: const Text('Community'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
      ),
      body: Stack(
        children: [
          // --- 1. BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. CONTENT ---
          FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'The Locker Room',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: MindSportTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect, share, and recover with fellow athletes.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // --- SEARCH BAR ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search topics...",
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- TOPIC CATEGORIES ---
                const Text(
                  "Discussion Boards",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MindSportTheme.darkText),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.1,
                  child: _buildTopicCard(
                    context,
                    title: "General Hangout",
                    subtitle: "Daily check-ins and casual chat.",
                    icon: Icons.coffee,
                    color: MindSportTheme.softGreen,
                    memberCount: "128 online",
                  ),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.2,
                  child: _buildTopicCard(
                    context,
                    title: "Injury & Rehab",
                    subtitle: "Support for the road to recovery.",
                    icon: Icons.healing,
                    color: const Color(0xFFE57373).withOpacity(0.3), // Soft Red
                    memberCount: "45 online",
                  ),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.3,
                  child: _buildTopicCard(
                    context,
                    title: "Pre-Game Nerves",
                    subtitle: "Strategies to handle the pressure.",
                    icon: Icons.psychology,
                    color: MindSportTheme.softLavender,
                    memberCount: "82 online",
                  ),
                ),
                const SizedBox(height: 16),

                _FadeInSlide(
                  animation: _fadeAnimation,
                  delay: 0.4,
                  child: _buildTopicCard(
                    context,
                    title: "Wins & Highlights",
                    subtitle: "Celebrate your victories here!",
                    icon: Icons.emoji_events,
                    color: Colors.orangeAccent.withOpacity(0.3),
                    memberCount: "67 online",
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("New post creation coming soon!")),
          );
        },
        backgroundColor: MindSportTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Post", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTopicCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required String memberCount,
      }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening $title...")),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          memberCount,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helpers (Reused from Home) ---
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