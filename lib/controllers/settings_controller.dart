import 'package:flutter/material.dart';

import '../models/app_mode.dart';
import '../services/settings_storage_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._storageService);

  final SettingsStorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;
  AppMode _appMode = AppMode.general;

  ThemeMode get themeMode => _themeMode;
  AppMode get appMode => _appMode;

  Future<void> loadSettings() async {
    _themeMode = await _storageService.loadThemeMode();
    _appMode = await _storageService.loadAppMode();
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

  Future<void> setAppMode(AppMode appMode) async {
    if (_appMode == appMode) {
      return;
    }

    _appMode = appMode;
    notifyListeners();
    await _storageService.saveAppMode(appMode);
  }
}
