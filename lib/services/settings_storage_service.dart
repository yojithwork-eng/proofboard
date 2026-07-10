import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_mode.dart';

class SettingsStorageService {
  static const String _themeModeKey = 'proofboard_theme_mode';
  static const String _appModeKey = 'proofboard_app_mode';

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final savedValue = preferences.getString(_themeModeKey);

    return switch (savedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    final value = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await preferences.setString(_themeModeKey, value);
  }

  Future<AppMode> loadAppMode() async {
    final preferences = await SharedPreferences.getInstance();
    final savedValue = preferences.getString(_appModeKey);

    return AppModeDisplay.fromName(savedValue);
  }

  Future<void> saveAppMode(AppMode appMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_appModeKey, appMode.name);
  }
}
