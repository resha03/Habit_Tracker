import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';

  // Categories
  static const List<String> habitCategories = [
    'Exercise',
    'Study',
    'Health',
    'Meditation',
    'Reading',
    'Sleep',
    'Nutrition',
    'Work',
    'Social',
    'Creative',
    'Other',
  ];

  // Category Colors
  static final Map<String, Color> categoryColors = {
    'Exercise': Colors.red,
    'Study': Colors.blue,
    'Health': Colors.green,
    'Meditation': Colors.purple,
    'Reading': Colors.orange,
    'Sleep': Colors.indigo,
    'Nutrition': Colors.teal,
    'Work': Colors.amber,
    'Social': Colors.pink,
    'Creative': Colors.lime,
    'Other': Colors.grey,
  };

  // Validation
  static const int minHabitNameLength = 2;
  static const int maxHabitNameLength = 50;
  static const int minDescriptionLength = 0;
  static const int maxDescriptionLength = 200;

  // Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 2);

  // Storage
  static const String habitsBox = 'habits';
  static const String userBox = 'user';
  static const String encryptionKeyBox = 'encryption_key';

  // Firebase
  static const String firebaseUsersCollection = 'users';
  static const String firebaseHabitsCollection = 'habits';

  // Offline
  static const Duration offlineSyncInterval = Duration(minutes: 5);
}
