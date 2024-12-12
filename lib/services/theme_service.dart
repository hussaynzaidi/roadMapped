import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _key = 'isDarkMode';
  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  bool get isDarkMode => _prefs.getBool(_key) ?? false;

  Future<void> toggleTheme() async {
    await _prefs.setBool(_key, !isDarkMode);
    notifyListeners();
  }
}
