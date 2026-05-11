import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('Valid habit name passes validation', () {
      expect(Validators.validateHabitName('Morning Exercise'), isNull);
    });

    test('Empty habit name fails validation', () {
      expect(Validators.validateHabitName(''), isNotNull);
      expect(Validators.validateHabitName(null), isNotNull);
    });

    test('Too short habit name fails validation', () {
      expect(Validators.validateHabitName('A'), isNotNull);
    });

    test('Too long habit name fails validation', () {
      final longName = 'A' * 51;
      expect(Validators.validateHabitName(longName), isNotNull);
    });

    test('Valid email passes validation', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('Invalid email fails validation', () {
      expect(Validators.validateEmail('invalid.email'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('Valid password passes validation', () {
      expect(Validators.validatePassword('password123'), isNull);
    });

    test('Short password fails validation', () {
      expect(Validators.validatePassword('short'), isNotNull);
    });

    test('Empty password fails validation', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('Valid goal days passes validation', () {
      expect(Validators.validateGoalDays('30'), isNull);
      expect(Validators.validateGoalDays('365'), isNull);
    });

    test('Invalid goal days fails validation', () {
      expect(Validators.validateGoalDays('0'), isNotNull);
      expect(Validators.validateGoalDays('366'), isNotNull);
      expect(Validators.validateGoalDays('invalid'), isNotNull);
    });

    test('Valid description passes validation', () {
      expect(
        Validators.validateDescription('This is a valid description'),
        isNull,
      );
      expect(Validators.validateDescription(''), isNull);
      expect(Validators.validateDescription(null), isNull);
    });

    test('Too long description fails validation', () {
      final longDesc = 'A' * 201;
      expect(Validators.validateDescription(longDesc), isNotNull);
    });
  });
}
