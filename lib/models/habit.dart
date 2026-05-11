import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final String category; // Exercise, Study, Health, Meditation, etc.
  final DateTime createdAt;
  final List<DateTime> completedDates; // Dates when habit was completed
  final int currentStreak; // Number of consecutive days
  final int longestStreak; // Longest streak achieved
  final String? color; // Hex color code
  final String? iconData; // Icon identifier
  final int goalDays; // Target number of completions
  final bool isActive;

  Habit({
    String? id,
    required this.name,
    required this.description,
    required this.category,
    DateTime? createdAt,
    this.completedDates = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.color,
    this.iconData,
    this.goalDays = 30,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Get completion percentage
  double get completionPercentage {
    if (goalDays == 0) return 0;
    return (completedDates.length / goalDays).clamp(0, 1);
  }

  /// Check if habit was completed today
  bool isCompletedToday() {
    final today = DateTime.now();
    return completedDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );
  }

  /// Check if habit was completed on a specific date
  bool isCompletedOnDate(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Add completion for today
  Habit addCompletion() {
    final today = DateTime.now();
    if (!isCompletedToday()) {
      final newCompletedDates = [...completedDates, today];
      final newStreak = _calculateStreak(newCompletedDates);
      return copyWith(
        completedDates: newCompletedDates,
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      );
    }
    return this;
  }

  /// Remove today's completion
  Habit removeCompletion() {
    final today = DateTime.now();
    final newCompletedDates =
        completedDates.where((date) => !_isSameDay(date, today)).toList();
    return copyWith(
      completedDates: newCompletedDates,
      currentStreak: _calculateStreak(newCompletedDates),
    );
  }

  /// Calculate current streak
  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sorted = List<DateTime>.from(dates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastDate;

    for (var date in sorted) {
      if (lastDate == null) {
        streak = 1;
        lastDate = date;
      } else {
        final difference = lastDate.difference(date).inDays;
        if (difference == 1) {
          streak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Create a copy with modified fields
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    int? currentStreak,
    int? longestStreak,
    String? color,
    String? iconData,
    int? goalDays,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      color: color ?? this.color,
      iconData: iconData ?? this.iconData,
      goalDays: goalDays ?? this.goalDays,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'completedDates':
          completedDates.map((date) => date.toIso8601String()).toList(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'color': color,
      'iconData': iconData,
      'goalDays': goalDays,
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedDates: (json['completedDates'] as List<dynamic>)
          .cast<String>()
          .map((date) => DateTime.parse(date))
          .toList(),
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      color: json['color'] as String?,
      iconData: json['iconData'] as String?,
      goalDays: json['goalDays'] as int? ?? 30,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  String toString() => 'Habit(id: $id, name: $name, currentStreak: $currentStreak)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ category.hashCode;
}
