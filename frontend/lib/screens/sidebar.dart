import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/services/auth_provider.dart';
import 'package:mindsport/services/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  // --- LOGIC: Open External Link ---
  Future<void> _launchForumUrl() async {
    // Your specific URL
    const url = 'https://mindsport-chatterbox.lovable.app';

    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch url: $e');
    }
  }

  // --- VISUALS: Consolidated Tile Builder ---
  Widget _buildListTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? routeName, // Optional: if navigation
        VoidCallback? onTap, // Optional: if custom action (like URL)
      }) {
    // Check if this tile is the currently active page (for highlighting)
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = (routeName != null && currentRoute == routeName);

    // Dark Theme Colors
    final Color iconColor = isSelected ? Colors.white : Colors.white.withOpacity(0.9);
    final Color textColor = isSelected ? Colors.white : Colors.white.withOpacity(0.9);
    final Color tileColor = isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Nunito',
        ),
      ),
      tileColor: tileColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: () {
        Navigator.pop(context); // Always close the drawer first

        if (onTap != null) {
          // Case A: Custom Action (URL or Logout)
          onTap();
        } else if (routeName != null && !isSelected) {
          // Case B: Navigation
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We access providers for user info and logout logic
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Drawer(
      child: Container(
        color: const Color(0xFF2D2D2D), // Your Dark Background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 24.0, bottom: 30.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'mindsport.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),

            // --- Navigation Items ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildListTile(context, icon: Icons.home_outlined, title: 'Home', routeName: '/home'),
                  _buildListTile(context, icon: Icons.chat_bubble_outline, title: 'ChatBot', routeName: '/chat'),
                  _buildListTile(context, icon: Icons.fitness_center, title: 'Exercises', routeName: '/exercises'),
                  _buildListTile(context, icon: Icons.notifications_none, title: 'Reminders', routeName: '/reminders'),
                  _buildListTile(context, icon: Icons.library_books_outlined, title: 'Resources', routeName: '/resources'),

                  // External Link
                  _buildListTile(
                      context,
                      icon: Icons.people_outline,
                      title: 'Community Forum',
                      onTap: _launchForumUrl
                  ),
                ],
              ),
            ),

            // --- Bottom Section ---
            const Divider(color: Colors.white24, indent: 20, endIndent: 20),

            // Profile Link
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'A',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                ),
              ),
              title: Text(
                  user?.name ?? 'User Profile',
                  style: const TextStyle(color: Colors.white70, fontFamily: 'Nunito')
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white70),
                label: const Text('Logout', style: TextStyle(color: Colors.white70)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);

                  // Use AuthProvider for clean logout
                  authProvider.logout(userProvider);

                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}