import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindsport/services/auth_provider.dart';
import 'package:mindsport/services/user_provider.dart';
import 'package:mindsport/main.dart'; // Import theme colors

class AppSidebar extends StatelessWidget {
const AppSidebar({super.key});

// --- TILE BUILDER ---
Widget _buildListTile(
BuildContext context, {
required IconData icon,
required String title,
required String routeName,
}) {
// Check if this tile is the currently active page
final String? currentRoute = ModalRoute.of(context)?.settings.name;
final bool isSelected = (currentRoute == routeName);

// Theme Colors
final Color activeColor = MindSportTheme.primaryGreen;
final Color inactiveColor = MindSportTheme.darkText;

return ListTile(
leading: Icon(icon, color: isSelected ? activeColor : inactiveColor.withOpacity(0.6)),
title: Text(
title,
style: TextStyle(
fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
color: isSelected ? activeColor : inactiveColor,
fontFamily: 'Nunito',
),
),
// Subtle background highlight for active item
tileColor: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
onTap: () {
Navigator.pop(context); // Always close the drawer first

if (!isSelected) {
// Navigate to the internal route
Navigator.pushNamed(context, routeName);
}
},
);
}

// --- GAMES SECTION BUILDER ---
Widget _buildGamesSection(BuildContext context) {
return ExpansionTile(
leading: CircleAvatar(
backgroundColor: Colors.amber.withOpacity(0.2),
child: const Icon(Icons.videogame_asset, color: Colors.amber, size: 22),
),
title: const Text(
'Brain Games',
style: TextStyle(
fontWeight: FontWeight.bold,
color: MindSportTheme.darkText,
fontFamily: 'Nunito',
),
),
children: [
// Memory Flip Card Game
ListTile(
leading: Container(
width: 32,
height: 32,
decoration: BoxDecoration(
color: MindSportTheme.primaryGreen.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: const Icon(Icons.grid_view, size: 16, color: MindSportTheme.primaryGreen),
),
title: const Text(
'Memory Match',
style: TextStyle(
fontSize: 14,
fontFamily: 'Nunito',
color: Colors.black87,
),
),
subtitle: const Text(
'Flip & match cards',
style: TextStyle(fontSize: 12, color: Colors.grey),
),
trailing: Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: MindSportTheme.primaryGreen.withOpacity(0.1),
borderRadius: BorderRadius.circular(12),
),
child: const Text(
'NEW',
style: TextStyle(
fontSize: 10,
color: MindSportTheme.primaryGreen,
fontWeight: FontWeight.bold,
),
),
),
onTap: () {
Navigator.pop(context);
Navigator.pushNamed(context, '/memory-game');
},
),

// Color Match Reflex Game
ListTile(
leading: Container(
width: 32,
height: 32,
decoration: BoxDecoration(
color: Colors.purple.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: const Icon(Icons.color_lens, size: 16, color: Colors.purple),
),
title: const Text(
'Color Reflex',
style: TextStyle(
fontSize: 14,
fontFamily: 'Nunito',
color: Colors.black87,
),
),
subtitle: const Text(
'Quick reaction test',
style: TextStyle(fontSize: 12, color: Colors.grey),
),
onTap: () {
Navigator.pop(context);
Navigator.pushNamed(context, '/color-game');
},
),
],
);
}

@override
Widget build(BuildContext context) {
final user = Provider.of<UserProvider>(context).user;

return Drawer(
backgroundColor: MindSportTheme.primaryBackground, // Matches app background
child: Column(
children: [
// --- HEADER ---
UserAccountsDrawerHeader(
decoration: const BoxDecoration(
color: MindSportTheme.softLavender, // Lavender header
),
accountName: Text(
user?.name ?? 'Athlete',
style: const TextStyle(
color: MindSportTheme.darkText,
fontWeight: FontWeight.bold,
fontSize: 18,
fontFamily: 'Nunito',
),
),
accountEmail: Text(
user?.email ?? '',
style: const TextStyle(color: Colors.black54, fontFamily: 'Nunito'),
),
currentAccountPicture: CircleAvatar(
backgroundColor: Colors.white,
child: Text(
user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'A',
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: MindSportTheme.primaryGreen,
),
),
),
),

// --- NAVIGATION ITEMS ---
Expanded(
child: ListView(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
children: [
_buildListTile(context, icon: Icons.home_outlined, title: 'Home', routeName: '/home'),
_buildListTile(context, icon: Icons.person_outline, title: 'Profile', routeName: '/profile'),
_buildListTile(context, icon: Icons.alarm, title: 'Reminders', routeName: '/reminders'),
_buildListTile(context, icon: Icons.fitness_center, title: 'Mental Gym', routeName: '/exercises'),

// Games Section (with divider before and after)
const Divider(height: 30, thickness: 1, indent: 16, endIndent: 16),
_buildGamesSection(context),
const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),

// In sidebar.dart, add this to the navigation items list:
_buildListTile(context, icon: Icons.restaurant, title: 'Diet Plan', routeName: '/diet-plan'),
_buildListTile(context, icon: Icons.chat_bubble_outline, title: 'Chat Bot', routeName: '/chat'),
_buildListTile(context, icon: Icons.library_books_outlined, title: 'Resources', routeName: '/resources'),
_buildListTile(context, icon: Icons.people_outline, title: 'Community Forum', routeName: '/forum'),
],
),
),

// --- LOGOUT ---
Padding(
padding: const EdgeInsets.all(16.0),
child: ListTile(
leading: const Icon(Icons.logout, color: Colors.black54),
title: const Text('Logout', style: TextStyle(fontFamily: 'Nunito')),
onTap: () {
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final userProvider = Provider.of<UserProvider>(context, listen: false);

authProvider.logout(userProvider);

Navigator.pop(context);
Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
},
),
),
const SizedBox(height: 10),
],
),
);
}
}