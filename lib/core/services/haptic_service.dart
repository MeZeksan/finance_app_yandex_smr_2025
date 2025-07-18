import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static const String _hapticEnabledKey = 'haptic_enabled';
  
  late SharedPreferences _prefs;
  bool _isEnabled = true;
  
  bool get isEnabled => _isEnabled;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }
  
  void _loadSettings() {
    _isEnabled = _prefs.getBool(_hapticEnabledKey) ?? true;
  }
  
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _prefs.setBool(_hapticEnabledKey, enabled);
  }
  
  /// Легкая вибрация для переключения табов
  void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }
  
  /// Средняя вибрация для кнопок
  void mediumImpact() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
  }
  
  /// Сильная вибрация для важных действий
  void heavyImpact() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
  }
  
  /// Вибрация для выбора
  void selectionClick() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }
  
  /// Вибрация для успешных действий
  void success() {
    if (!_isEnabled) return;
    HapticFeedback.vibrate();
  }
} 