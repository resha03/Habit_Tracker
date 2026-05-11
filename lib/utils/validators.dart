import 'constants.dart';

class Validators {
  /// Validate habit name
  static String? validateHabitName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Habit name is required';
    }
    if (value.length < AppConstants.minHabitNameLength) {
      return 'Habit name must be at least ${AppConstants.minHabitNameLength} characters';
    }
    if (value.length > AppConstants.maxHabitNameLength) {
      return 'Habit name must be less than ${AppConstants.maxHabitNameLength} characters';
    }
    return null;
  }

  /// Validate habit description
  static String? validateDescription(String? value) {
    if (value == null) {
      return null;
    }
    if (value.length > AppConstants.maxDescriptionLength) {
      return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    const emailPattern =
        r'^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$';
    final regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate goal days
  static String? validateGoalDays(String? value) {
    if (value == null || value.isEmpty) {
      return 'Goal days is required';
    }
    final days = int.tryParse(value);
    if (days == null || days < 1 || days > 365) {
      return 'Goal days must be between 1 and 365';
    }
    return null;
  }
}
