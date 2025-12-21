import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Глобальный контроллер темы с сохранением выбора пользователя.
///
/// Поддерживает три режима:
/// - [ThemeMode.system]  — по умолчанию
/// - [ThemeMode.light]
/// - [ThemeMode.dark]
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  static const _prefsKey = 'themeMode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    switch (stored) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _mode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_prefsKey, value);
  }
}




