import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:flutter/material.dart';

class AnalysisHeader extends StatelessWidget {
  const AnalysisHeader({
    super.key,
    required this.topPadding,
  });

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final themeService = ServiceLocator.themeService;
    
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeService.headerColor,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Анализ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: themeService.textColor,
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back,
                          color: themeService.textColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 