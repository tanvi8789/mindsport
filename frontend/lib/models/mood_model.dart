class MoodEntry {
  final String id;
  final String mood; // 'happy', 'sad', etc.
  final String? reason;
  final DateTime date;
  final int sleep;
  final int physical;

  MoodEntry({
    required this.id,
    required this.mood,
    this.reason,
    required this.date,
    this.sleep = 5,    // Default to 5 if missing
    this.physical = 5, // Default to 5 if missing
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['_id'],
      mood: json['mood'],
      reason: json['reason'],
      // Parse the ISO date string from MongoDB
      date: DateTime.parse(json['createdAt']),
      sleep: json['sleep'] ?? 5,
      physical: json['physical'] ?? 5
    );
  }
}