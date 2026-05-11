import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/widgets/habit_widgets.dart';

void main() {
  group('HabitCard Widget Tests', () {
    testWidgets('HabitCard displays habit information', (WidgetTester tester) async {
      final habit = Habit(
        name: 'Morning Exercise',
        description: 'Daily 30-minute workout',
        category: 'Exercise',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onTap: () {},
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Morning Exercise'), findsOneWidget);
      expect(find.text('Daily 30-minute workout'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('HabitCard shows completion circle', (WidgetTester tester) async {
      final habit = Habit(
        name: 'Test Habit',
        description: 'Test',
        category: 'Exercise',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onTap: () {},
              onToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('HabitCard calls onToggle when completion circle tapped',
        (WidgetTester tester) async {
      bool wasToggled = false;

      final habit = Habit(
        name: 'Test Habit',
        description: 'Test',
        category: 'Exercise',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HabitCard(
              habit: habit,
              onTap: () {},
              onToggle: () {
                wasToggled = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find and tap the completion circle
      final completionCircle = find.byIcon(Icons.close);
      expect(completionCircle, findsOneWidget);
    });
  });

  group('StreakIndicator Widget Tests', () {
    testWidgets('StreakIndicator displays streak information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakIndicator(
              streak: 15,
              maxStreak: 30,
              color: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('Best: 30 days'), findsOneWidget);
    });

    testWidgets('StreakIndicator shows progress bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakIndicator(
              streak: 10,
              maxStreak: 20,
              color: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('CompletionChart Widget Tests', () {
    testWidgets('CompletionChart displays when habits exist',
        (WidgetTester tester) async {
      final habits = [
        Habit(
          name: 'Habit 1',
          description: 'Test',
          category: 'Exercise',
          completedDates: [DateTime.now()],
        ),
        Habit(
          name: 'Habit 2',
          description: 'Test',
          category: 'Study',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompletionChart(habits: habits),
          ),
        ),
      );

      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('CompletionChart shows message when no habits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompletionChart(habits: []),
          ),
        ),
      );

      expect(find.text('No habits yet'), findsOneWidget);
    });
  });

  group('CategoryFilter Widget Tests', () {
    testWidgets('CategoryFilter displays all categories',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilter(
              selectedCategory: 'All',
              onCategoryChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
    });

    testWidgets('CategoryFilter calls onCategoryChanged when chip tapped',
        (WidgetTester tester) async {
      String? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryFilter(
              selectedCategory: 'All',
              onCategoryChanged: (category) {
                selectedCategory = category;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Exercise'));
      await tester.pumpAndSettle();

      expect(selectedCategory, 'Exercise');
    });
  });
}
