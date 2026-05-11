import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(AppConstants.userBox); // Reuse auth box for theme
      final themeIndex = box.get(_themeKey, defaultValue: 0) as int?;
      _themeMode = ThemeMode.values[themeIndex ?? 2]; // default system
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    try {
      final box = Hive.box(AppConstants.userBox);
      await box.put(_themeKey, mode.index);
    } catch (e) {
      print('Failed to save theme: $e');
    }
    notifyListeners();
  }
}
