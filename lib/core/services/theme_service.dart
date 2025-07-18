import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _useSystemThemeKey = 'use_system_theme';
  static const String _primaryColorKey = 'primary_color';
  static const String _isDarkThemeKey = 'is_dark_theme';
  
  late SharedPreferences _prefs;
  bool _useSystemTheme = true;
  bool _isDarkTheme = false;
  Color _primaryColor = Colors.green;
  
  bool get useSystemTheme => _useSystemTheme;
  bool get isDarkTheme => _isDarkTheme;
  Color get primaryColor => _primaryColor;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  void _loadSettings() {
    _useSystemTheme = _prefs.getBool(_useSystemThemeKey) ?? true;
    _isDarkTheme = _prefs.getBool(_isDarkThemeKey) ?? false;
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
  
  Future<void> setDarkTheme(bool value) async {
    _isDarkTheme = value;
    await _prefs.setBool(_isDarkThemeKey, value);
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
      scaffoldBackgroundColor: const Color(0xFFFEF7FF),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
  
  ThemeData getDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
  
  // Методы для получения цветов приложения
  Color get headerColor => _primaryColor;
  Color get containerColor => _isDarkMode 
    ? _primaryColor.withValues(alpha: 0.2)
    : _primaryColor.withValues(alpha: 0.1);
  Color get textColor => _isDarkMode 
    ? Colors.white 
    : const Color(0xFF1D1B20);
  Color get backgroundColor => _isDarkMode 
    ? const Color(0xFF121212) 
    : const Color(0xFFFEF7FF);
    
  bool get isDarkMode => _isDarkMode;
    
  bool get _isDarkMode {
    if (_useSystemTheme) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    } else {
      return _isDarkTheme;
    }
  }
} 