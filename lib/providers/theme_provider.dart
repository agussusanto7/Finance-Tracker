import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  int _selectedRadio = 0;

  bool get isDarkMode => _isDarkMode;
  int get selectedRadio => _selectedRadio;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    _selectedRadio = _isDarkMode ? 1 : 0;
    notifyListeners();
  }

  Future<void> toggleTheme(int value) async {
    _selectedRadio = value;
    _isDarkMode = value == 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _selectedRadio = _isDarkMode ? 1 : 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);

    notifyListeners();
  }
}
