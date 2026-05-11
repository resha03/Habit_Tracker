import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  // Getters
  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  /// Initialize provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      // Initialize services
      await _storageService.initialize();
      await _firebaseService.initialize();
      _connectivityService.initialize();

      // Load habits from local storage
      _habits = await _storageService.getAllHabits();
      _sortHabits();

      // Check connectivity
      _isOnline = await _connectivityService.isOnline();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize: $e');
      _setLoading(false);
    }
  }

  /// Add new habit
  Future<void> addHabit(Habit habit) async {
    try {
      _clearError();
      await _storageService.saveHabit(habit);
      _habits.add(habit);
      _sortHabits();

      // Sync to Firebase if online
      if (_isOnline) {
        await _firebaseService.saveHabit('user', habit.toJson());
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to add habit: $e');
    }
  }

  /// Update habit
  Future<void> updateHabit(Habit habit) async {
    try {
      _clearError();
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
        await _storageService.saveHabit(habit);

        // Sync to Firebase if online
        if (_isOnline) {
          await _firebaseService.saveHabit('user', habit.toJson());
        }

        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update habit: $e');
    }
  }

  /// Delete habit
  Future<void> deleteHabit(String habitId) async {
    try {
      _clearError();
      _habits.removeWhere((h) => h.id == habitId);
      await _storageService.deleteHabit(habitId);

      // Sync to Firebase if online
      if (_isOnline) {
        await _firebaseService.deleteHabit('user', habitId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete habit: $e');
    }
  }

  /// Toggle habit completion for today
  Future<void> toggleHabitCompletion(String habitId) async {
    try {
      _clearError();
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final updatedHabit = habit.isCompletedToday()
          ? habit.removeCompletion()
          : habit.addCompletion();

      await updateHabit(updatedHabit);
    } catch (e) {
      _setError('Failed to toggle completion: $e');
    }
  }

  /// Get habits for a specific date
  List<Habit> getHabitsForDate(DateTime date) {
    return _habits.where((h) => h.isCompletedOnDate(date)).toList();
  }

  /// Get total completion percentage
  double getTotalCompletionPercentage() {
    if (_habits.isEmpty) return 0;
    final total = _habits.fold<double>(0, (sum, h) => sum + h.completionPercentage);
    return total / _habits.length;
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalHabits': _habits.length,
      'activeHabits': _habits.where((h) => h.isActive).length,
      'totalCompletions': _habits.fold(0, (sum, h) => sum + h.completedDates.length),
      'averageStreak': _habits.isEmpty
          ? 0
          : _habits.fold(0, (sum, h) => sum + h.currentStreak) / _habits.length,
      'longestStreak': _habits.isEmpty
          ? 0
          : _habits.map((h) => h.longestStreak).reduce((max, val) => val > max ? val : max),
    };
  }

  /// Sync with Firebase
  Future<void> _syncWithFirebase() async {
    try {
      final firebaseHabitsData = await _firebaseService.getHabits('user');

      for (var habitData in firebaseHabitsData) {
        try {
          final firebaseHabit = Habit.fromJson(habitData);
          final existingIndex = _habits.indexWhere((h) => h.id == firebaseHabit.id);

          if (existingIndex >= 0) {
            // If habit exists both locally and in Firebase, use the newer one
            if (firebaseHabit.createdAt.isAfter(_habits[existingIndex].createdAt)) {
              _habits[existingIndex] = firebaseHabit;
              await _storageService.saveHabit(firebaseHabit);
            }
          } else {
            // Add new habit from Firebase
            _habits.add(firebaseHabit);
            await _storageService.saveHabit(firebaseHabit);
          }
        } catch (e) {
          debugPrint('Error parsing Firebase habit: $e');
        }
      }

      _sortHabits();
      notifyListeners();
    } catch (e) {
      // Silently fail - offline support
      debugPrint('Sync failed: $e');
    }
  }

  /// Sort habits
  void _sortHabits() {
    _habits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
  }

  /// Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all habits
  Future<void> clearAllHabits() async {
    try {
      _clearError();
      await _storageService.clearAllHabits();
      _habits.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear habits: $e');
    }
  }

  /// Export habits
  Future<String> exportHabits() async {
    try {
      _clearError();
      return await _storageService.exportHabits();
    } catch (e) {
      _setError('Failed to export habits: $e');
      rethrow;
    }
  }

  /// Import habits
  Future<void> importHabits(String encryptedData) async {
    try {
      _clearError();
      await _storageService.importHabits(encryptedData);
      _habits = await _storageService.getAllHabits();
      _sortHabits();
      notifyListeners();
    } catch (e) {
      _setError('Failed to import habits: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _storageService.close();
    super.dispose();
  }
}
