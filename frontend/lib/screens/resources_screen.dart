import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mindsport/main.dart'; // Theme
import 'package:mindsport/screens/sidebar.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        title: const Text('Wellness Resources'),
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
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Learn & Train',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MindSportTheme.darkText
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Curated articles, music, and workouts to boost your game.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // --- 1. EDUCATIONAL ARTICLES ---
              _buildSection(
                title: "Educational Articles",
                icon: Icons.article_outlined,
                color: MindSportTheme.primaryGreen,
                items: [
                  _ResourceItem(
                    title: "Understanding Performance Anxiety",
                    subtitle: "Why it happens and how to use it",
                    icon: Icons.read_more,
                    action: () => _launchUrl('https://www.google.com/search?q=athlete+performance+anxiety'),
                  ),
                  _ResourceItem(
                    title: "Sleep & Reaction Time",
                    subtitle: "The science of recovery",
                    icon: Icons.bedtime_outlined,
                    action: () => _launchUrl('https://www.google.com/search?q=sleep+and+athletic+performance'),
                  ),
                  _ResourceItem(
                    title: "Coping with Long-term Injury",
                    subtitle: "Staying mentally fit while recovering",
                    icon: Icons.healing,
                    action: () => _launchUrl('https://www.google.com/search?q=psychology+of+sports+injury'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- 2. MUSIC PLAYLISTS ---
              _buildSection(
                title: "Audio & Music",
                icon: Icons.headphones,
                color: MindSportTheme.softLavender,
                items: [
                  _ResourceItem(
                    title: "Pre-game Hype",
                    subtitle: "High energy tracks on Spotify",
                    icon: Icons.music_note,
                    action: () => _launchUrl('https://open.spotify.com/genre/workout'),
                  ),
                  _ResourceItem(
                    title: "Post-game Calm",
                    subtitle: "Lo-fi & Ambient for recovery",
                    icon: Icons.nightlight_round,
                    action: () => _launchUrl('https://open.spotify.com/genre/sleep'),
                  ),
                  _ResourceItem(
                    title: "Guided Visualization",
                    subtitle: "10-minute mental rehearsal",
                    icon: Icons.visibility,
                    action: () => _launchUrl('https://www.youtube.com/results?search_query=guided+visualization+for+athletes'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- 3. WORKOUT ROUTINES (NEW) ---
              _buildSection(
                title: "Workout Routines",
                icon: Icons.fitness_center,
                color: Colors.orangeAccent.withOpacity(0.8), // Distinct color
                items: [
                  _ResourceItem(
                    title: "Full Body HIIT",
                    subtitle: "20-minute intense conditioning",
                    icon: Icons.play_circle_fill,
                    action: () => _launchUrl('https://youtu.be/M0uO8X3_tEA?si=dupZxyHGRY8QmL2c'),
                  ),
                  _ResourceItem(
                    title: "Yoga for Athletes",
                    subtitle: "Improve flexibility & mobility",
                    icon: Icons.self_improvement,
                    action: () => _launchUrl('https://youtu.be/wCUI1bwlJqA?si=goA6oscv3gOyBCFx'),
                  ),
                  _ResourceItem(
                    title: "Core Strength",
                    subtitle: "Stability essentials",
                    icon: Icons.accessibility_new,
                    action: () => _launchUrl('https://youtu.be/dJlFmxiL11s?si=wJ3f-Rz2cd4oJsNo'),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper to build specific resource rows ---
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  // --- Helper to build the accordion sections ---
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_ResourceItem> items,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: items.map((item) {
            return ListTile(
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item.subtitle),
              trailing: Icon(Icons.arrow_forward_ios, size: 14, color: color),
              onTap: item.action,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ResourceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback action;

  _ResourceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.action,
  });
}

// --- Reused Background ---
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