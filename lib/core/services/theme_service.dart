import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _useSystemThemeKey = 'use_system_theme';
  static const String _primaryColorKey = 'primary_color';
  
  late SharedPreferences _prefs;
  bool _useSystemTheme = true;
  Color _primaryColor = Colors.green;
  
  bool get useSystemTheme => _useSystemTheme;
  Color get primaryColor => _primaryColor;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  void _loadSettings() {
    _useSystemTheme = _prefs.getBool(_useSystemThemeKey) ?? true;
    final colorValue = _prefs.getInt(_primaryColorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    notifyListeners();
  }
  
  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    await _prefs.setBool(_useSystemThemeKey, value);
    notifyListeners();
  }
  
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _prefs.setInt(_primaryColorKey, color.toARGB32());
    notifyListeners();
  }
  
  ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }
  
  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
} 