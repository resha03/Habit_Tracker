import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import 'security_service.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  late Box<String> _habitsBox;
  final _securityService = SecurityService();

  /// Initialize storage
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _habitsBox = await Hive.openBox<String>(AppConstants.habitsBox);
      await _securityService.initializeEncryption();
    } catch (e) {
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  /// Save habit
  Future<void> saveHabit(Habit habit) async {
    try {
      final habitJson = habit.toJson();
      final encrypted = _securityService.encryptJson(habitJson);
      await _habitsBox.put(habit.id, encrypted);
    } catch (e) {
      throw StorageException('Failed to save habit: $e');
    }
  }

  /// Get habit by ID
  Future<Habit?> getHabit(String id) async {
    try {
      final encrypted = _habitsBox.get(id);
      if (encrypted == null) return null;
      final habitJson = _securityService.decryptJson(encrypted);
      return Habit.fromJson(habitJson);
    } catch (e) {
      throw StorageException('Failed to get habit: $e');
    }
  }

  /// Get all habits
  Future<List<Habit>> getAllHabits() async {
    try {
      final habits = <Habit>[];
      for (var encryptedData in _habitsBox.values) {
        try {
          final habitJson = _securityService.decryptJson(encryptedData);
          habits.add(Habit.fromJson(habitJson));
        } catch (e) {
          // Skip corrupted habits
          continue;
        }
      }
      return habits;
    } catch (e) {
      throw StorageException('Failed to get all habits: $e');
    }
  }

  /// Delete habit
  Future<void> deleteHabit(String id) async {
    try {
      await _habitsBox.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete habit: $e');
    }
  }

  /// Clear all habits
  Future<void> clearAllHabits() async {
    try {
      await _habitsBox.clear();
    } catch (e) {
      throw StorageException('Failed to clear habits: $e');
    }
  }

  /// Export habits as JSON
  Future<String> exportHabits() async {
    try {
      final habits = await getAllHabits();
      final habitsList = habits.map((h) => h.toJson()).toList();
      final json = {'habits': habitsList};
      return _securityService.encryptJson(json);
    } catch (e) {
      throw StorageException('Failed to export habits: $e');
    }
  }

  /// Import habits from JSON
  Future<void> importHabits(String encryptedData) async {
    try {
      final json = _securityService.decryptJson(encryptedData);
      final habitsList = json['habits'] as List<dynamic>;
      for (var habitJson in habitsList) {
        final habit = Habit.fromJson(habitJson as Map<String, dynamic>);
        await saveHabit(habit);
      }
    } catch (e) {
      throw StorageException('Failed to import habits: $e');
    }
  }

  /// Close storage
  Future<void> close() async {
    try {
      await _habitsBox.close();
    } catch (e) {
      throw StorageException('Failed to close storage: $e');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
