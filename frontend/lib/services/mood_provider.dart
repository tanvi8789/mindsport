import 'package:flutter/material.dart';
import 'package:mindsport/services/api_client.dart';
import 'package:mindsport/models/mood_model.dart';

class MoodProvider with ChangeNotifier {
  String? _todaysMoodKeyword;
  String? get todaysMoodKeyword => _todaysMoodKeyword;

  final ApiClient _apiClient = ApiClient();

  List<MoodEntry> _moodHistory = [];
  bool _isLoadingHistory = false;
  Map<DateTime, String> _calendarMoods = {};

  Map<DateTime, String> get calendarMoods => _calendarMoods;
  bool get isLoadingHistory => _isLoadingHistory;

  // --- NEW: STREAK CALCULATION ---
  int get currentStreak {
    if (_moodHistory.isEmpty) return 0;

    // 1. Get unique dates only (ignore time)
    final uniqueDates = _moodHistory
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort newest to oldest

    if (uniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized = todayNormalized.subtract(const Duration(days: 1));

    // 2. Check if the streak is broken (latest entry is older than yesterday)
    if (uniqueDates.first.isBefore(yesterdayNormalized)) {
      return 0;
    }

    // 3. Count consecutive days
    int streak = 0;
    // We start checking from Today. If today is missing, we allow starting from Yesterday.
    DateTime checkDate = uniqueDates.contains(todayNormalized) ? todayNormalized : yesterdayNormalized;

    while (uniqueDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void selectMood(String keyword) {
    _todaysMoodKeyword = keyword;
    notifyListeners();
  }

  Future<void> fetchMoodHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    final response = await _apiClient.get('/moods/history');

    if (response is List) {
      _moodHistory = response.map((json) => MoodEntry.fromJson(json)).toList();
      _generateCalendarMap();
    } else {
      print("Error fetching mood history: $response");
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  void _generateCalendarMap() {
    _calendarMoods = {};
    for (var entry in _moodHistory) {
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      _calendarMoods[normalizedDate] = entry.mood;
    }
  }
}