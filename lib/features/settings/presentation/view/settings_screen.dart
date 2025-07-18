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

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: ListenableBuilder(
        listenable: _themeService,
        builder: (context, child) {
          return Column(
            children: [
              // Header
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFb2AE881),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: const Text(
                    'Настройки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, top:8, bottom: 8),
                          width: double.infinity,
                          child: Row(
                            children: [
                              const Text(
                                'Тёмная тема',
                                style: TextStyle(
                                  color: Color(0xFF1D1B20),
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _themeService.useSystemTheme,
                                onChanged: (value) {
                                  _themeService.setUseSystemTheme(value);
                                },
                                activeColor: const Color.fromARGB(250, 26, 165, 88),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE6E6E6),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Основной цвет',
                                style: TextStyle(
                                  color: Color(0xFF1D1B20),
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
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF1D1B20),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                  _buildSettingTile('Звуки', Icons.volume_up),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                  _buildSettingTile('Хаптики', Icons.vibration),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                  _buildSettingTile('Код пароль', Icons.lock),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                  _buildSettingTile('Синхронизация', Icons.sync),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                  _buildSettingTile('Язык', Icons.language),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                  _buildSettingTile('О программе', Icons.info_outline),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1D1B20),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF1D1B20),
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
          title: const Text('Выберите основной цвет'),
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
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                _themeService.setPrimaryColor(pickerColor);
                Navigator.of(context).pop();
              },
              child: const Text('Выбрать'),
            ),
          ],
        );
      },
    );
  }


}
