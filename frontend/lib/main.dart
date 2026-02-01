import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services & Providers
import 'services/user_provider.dart';
import 'services/mood_provider.dart';
import 'services/reminder_provider.dart';
import 'services/auth_provider.dart';
import 'services/chat_provider.dart';
import 'services/notification_service.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/chat_page.dart';
import 'screens/community_forum.dart';
import 'screens/profile_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/mood_calender.dart';
import 'screens/resources_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/chat_session_screen.dart';
import 'package:mindsport/screens/memory_game_screen.dart';
import 'package:mindsport/screens/color_game_screen.dart';

// --- THEME DEFINITION ---
class MindSportTheme {
  static const Color primaryBackground = Color(0xFFF2F0EC); // Warm beige
  static const Color darkText = Color(0xFF333333); // Sharp dark text
  static const Color primaryGreen = Color(0xFF6B8E23); // Earthy olive/sage (Opaque)
  static const Color softGreen = Color(0xFFD5DABA); // Soft pastel green
  static const Color softPeach = Color(0xFFF3CEB3); // Soft pastel peach
  static const Color softLavender = Color(0xFFBAC0DA); // Soft pastel lavender
}

// --- MAIN ENTRY POINT ---
void main() async {
  // 1. Ensure Flutter bindings are initialized (Required for async main)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the Notification Service
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MoodProvider()),
        ChangeNotifierProvider(create: (context) => ReminderProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const MindSportApp(),
    ),
  );
}

class MindSportApp extends StatelessWidget {
  const MindSportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindSport App',
      theme: ThemeData(
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: MindSportTheme.primaryBackground,
        primaryColor: MindSportTheme.primaryGreen,

        // --- App Bar Theme ---
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: MindSportTheme.darkText),
          titleTextStyle: TextStyle(
            color: MindSportTheme.darkText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),

        // --- Button Theme ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MindSportTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ),

        // --- Text Field Theme ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          hintStyle: const TextStyle(color: Colors.black38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MindSportTheme.primaryGreen, width: 2),
          ),
        ),

        // --- Card Theme ---
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      // Start with the AuthWrapper to decide home/login
      home: const AuthWrapper(),

      // --- ROUTES ---
      // In the routes section, add:
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignupScreen(),
        '/reminders': (context) => const RemindersScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forum': (context) => const CommunityForum(),
        '/chat': (context) => const ChatPage(),
        '/chat-sessions': (context) => const ChatSessionScreen(), // Add this line
        '/history': (context) => const MoodHistoryScreen(),
        '/resources': (context) => const ResourcesScreen(),
        '/exercises': (context) => const ExercisesScreen(),
        '/memory-game': (context) => const MemoryGameScreen(),
        '/color-game': (context) => const ColorGameScreen(),
      },
    );
  }
}

/// AuthWrapper
/// This smart widget handles showing the correct screen based on login status.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticating:
      case AuthStatus.uninitialized:
      default:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}