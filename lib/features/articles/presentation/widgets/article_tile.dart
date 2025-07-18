import 'package:finance_app_yandex_smr_2025/features/articles/data/models/article.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/core/services/theme_service.dart';
import 'package:flutter/material.dart';

class ArticleTile extends StatefulWidget {
  final Article article;
  final bool isFirst;
  final bool isLast;

  const ArticleTile({
    super.key,
    required this.article,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<ArticleTile> createState() => _ArticleTileState();
}

class _ArticleTileState extends State<ArticleTile> {
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ServiceLocator.themeService;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _themeService.backgroundColor,
            border: Border(
              top: widget.isFirst ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Row(
              children: [
                // Emoji with background
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _themeService.containerColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      widget.article.emoji,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Article title
                Expanded(
                  child: Text(
                    widget.article.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: _themeService.textColor,
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