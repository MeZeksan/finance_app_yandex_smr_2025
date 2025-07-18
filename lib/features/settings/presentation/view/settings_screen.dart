import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/core/services/theme_service.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ServiceLocator.themeService;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;

    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _themeService.backgroundColor,
          body: Column(
            children: [
              // Header
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _themeService.headerColor,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: Text(
                    'Настройки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _themeService.textColor,
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _themeService.containerColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Text(
                                  'Системная тема',
                                  style: TextStyle(
                                    color: _themeService.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: _themeService.useSystemTheme,
                                  onChanged: (value) {
                                    _themeService.setUseSystemTheme(value);
                                  },
                                  activeColor: _themeService.headerColor,
                                ),
                              ],
                            ),
                          ),
                          if (!_themeService.useSystemTheme)
                            Container(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Text(
                                    'Тёмная тема',
                                    style: TextStyle(
                                      color: _themeService.textColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Switch(
                                    value: _themeService.isDarkTheme,
                                    onChanged: (value) {
                                      _themeService.setDarkTheme(value);
                                    },
                                    activeColor: _themeService.headerColor,
                                  ),
                                ],
                              ),
                            ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: _themeService.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Основной цвет',
                                  style: TextStyle(
                                    color: _themeService.textColor,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showColorPicker(context),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: _themeService.primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _themeService.isDarkMode 
                                          ? Colors.grey.shade600 
                                          : Colors.grey.shade300
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: _themeService.textColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Other settings
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _themeService.containerColor,
                      ),
                      child: Column(
                        children: [
                          _buildSettingTile('Звуки', Icons.volume_up),
                          Divider(
                            height: 1, 
                            thickness: 1, 
                            color: _themeService.isDarkMode ? Colors.grey.shade700 : const Color(0xFFE6E6E6)
                          ),
                          _buildSettingTile('Хаптики', Icons.vibration),
                          Divider(
                            height: 1, 
                            thickness: 1, 
                            color: _themeService.isDarkMode ? Colors.grey.shade700 : const Color(0xFFE6E6E6)
                          ),
                          _buildSettingTile('Код пароль', Icons.lock),
                          Divider(
                            height: 1, 
                            thickness: 1, 
                            color: _themeService.isDarkMode ? Colors.grey.shade700 : const Color(0xFFE6E6E6)
                          ),
                          _buildSettingTile('Синхронизация', Icons.sync),
                          Divider(
                            height: 1, 
                            thickness: 1, 
                            color: _themeService.isDarkMode ? Colors.grey.shade700 : const Color(0xFFE6E6E6)
                          ),
                          _buildSettingTile('Язык', Icons.language),
                          Divider(
                            height: 1, 
                            thickness: 1, 
                            color: _themeService.isDarkMode ? Colors.grey.shade700 : const Color(0xFFE6E6E6)
                          ),
                          _buildSettingTile('О программе', Icons.info_outline),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: _themeService.textColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: _themeService.textColor,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: _themeService.textColor,
            size: 24,
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = _themeService.primaryColor;
        
        return AlertDialog(
          backgroundColor: _themeService.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Выберите основной цвет',
            style: TextStyle(
              color: _themeService.textColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Отмена',
                style: TextStyle(color: _themeService.textColor),
              ),
            ),
            TextButton(
              onPressed: () {
                _themeService.setPrimaryColor(pickerColor);
                Navigator.of(context).pop();
              },
              child: Text(
                'Выбрать',
                style: TextStyle(color: _themeService.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
