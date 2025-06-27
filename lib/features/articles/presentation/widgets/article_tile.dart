import 'package:finance_app_yandex_smr_2025/features/articles/data/models/article.dart';
import 'package:flutter/material.dart';

class ArticleTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: isFirst ? const BorderSide(color: Color(0xFFE6E6E6)) : BorderSide.none,
          bottom: BorderSide(color: const Color(0xFFE6E6E6)),
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
                color: article.iconBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  article.emoji,
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
                article.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1D1B20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 