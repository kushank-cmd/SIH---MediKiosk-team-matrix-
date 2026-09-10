import 'package:flutter/material.dart';
import 'local_storage_service.dart';

/// App-wide controller managing light vs dark theme modes with persistent Hive storage.
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();

  factory ThemeController() => instance;

  ThemeController._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initializes theme mode from Hive offline storage at startup.
  Future<void> init() async {
    _isDarkMode = LocalStorageService.isDarkMode();
  }

  /// Toggles between light and dark modes, saves to Hive, and notifies listeners.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await LocalStorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Explicitly sets theme mode.
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode == isDark) return;
    _isDarkMode = isDark;
    await LocalStorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
