import 'package:flutter/material.dart';

import '../services/settings_storage_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._storageService);

  final SettingsStorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _storageService.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    notifyListeners();
    await _storageService.saveThemeMode(themeMode);
  }
}
