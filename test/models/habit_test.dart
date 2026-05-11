import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit creation with default values', () {
      final habit = Habit(
        name: 'Morning Exercise',
        description: 'Daily morning workout',
        category: 'Exercise',
      );

      expect(habit.name, 'Morning Exercise');
      expect(habit.description, 'Daily morning workout');
      expect(habit.category, 'Exercise');
      expect(habit.isActive, true);
      expect(habit.goalDays, 30);
      expect(habit.currentStreak, 0);
      expect(habit.completedDates.isEmpty, true);
    });

    test('Habit completion today', () {
      final habit = Habit(
        name: 'Reading',
        description: 'Read a book',
        category: 'Reading',
      );

      expect(habit.isCompletedToday(), false);

      final completedHabit = habit.addCompletion();
      expect(completedHabit.isCompletedToday(), true);
      expect(completedHabit.completedDates.length, 1);
    });

    test('Habit completion percentage', () {
      final habit = Habit(
        name: 'Study',
        description: 'Study for 1 hour',
        category: 'Study',
        goalDays: 30,
      );

      expect(habit.completionPercentage, 0.0);

      final updatedHabit = habit.copyWith(completedDates: [
        DateTime.now(),
        DateTime.now().subtract(const Duration(days: 1)),
      ]);

      expect(updatedHabit.completionPercentage, closeTo(2 / 30, 0.01));
    });

    test('Habit streak calculation', () {
      final today = DateTime.now();
      final dates = [
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
      ];

      final habit = Habit(
        name: 'Exercise',
        description: 'Daily workout',
        category: 'Exercise',
        completedDates: dates,
      );

      expect(habit.currentStreak, 3);
    });

    test('Habit streak breaks on non-consecutive days', () {
      final today = DateTime.now();
      final dates = [
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 3)), // Gap here
      ];

      final habit = Habit(
        name: 'Exercise',
        description: 'Daily workout',
        category: 'Exercise',
        completedDates: dates,
      );

      // Should only count the two consecutive days
      expect(habit.currentStreak, 2);
    });

    test('Habit remove completion', () {
      final today = DateTime.now();
      final habit = Habit(
        name: 'Reading',
        description: 'Read',
        category: 'Reading',
        completedDates: [today],
      );

      expect(habit.isCompletedToday(), true);

      final removedHabit = habit.removeCompletion();
      expect(removedHabit.isCompletedToday(), false);
      expect(removedHabit.completedDates.isEmpty, true);
    });

    test('Habit JSON serialization', () {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test',
        category: 'Exercise',
        goalDays: 60,
      );

      final json = habit.toJson();
      final reconstructed = Habit.fromJson(json);

      expect(reconstructed.name, habit.name);
      expect(reconstructed.description, habit.description);
      expect(reconstructed.category, habit.category);
      expect(reconstructed.goalDays, habit.goalDays);
    });

    test('Habit copyWith creates new instance', () {
      final habit1 = Habit(
        name: 'Original',
        description: 'Original desc',
        category: 'Exercise',
      );

      final habit2 = habit1.copyWith(name: 'Updated');

      expect(habit1.name, 'Original');
      expect(habit2.name, 'Updated');
      expect(habit2.category, habit1.category);
    });

    test('Habit equality', () {
      final habit1 = Habit(
        id: '123',
        name: 'Test',
        description: 'Test',
        category: 'Exercise',
      );

      final habit2 = Habit(
        id: '123',
        name: 'Test',
        description: 'Test',
        category: 'Exercise',
      );

      expect(habit1 == habit2, true);
    });

    test('Habit is completed on specific date', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final habit = Habit(
        name: 'Exercise',
        description: 'Workout',
        category: 'Exercise',
        completedDates: [today, yesterday],
      );

      expect(habit.isCompletedOnDate(today), true);
      expect(habit.isCompletedOnDate(yesterday), true);
      expect(habit.isCompletedOnDate(today.subtract(const Duration(days: 2))), false);
    });
  });
}
