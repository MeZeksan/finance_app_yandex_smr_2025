import 'package:finance_app_yandex_smr_2025/features/analysis/data/models/category_analysis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryAnalysisTile extends StatelessWidget {
  final CategoryAnalysis category;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const CategoryAnalysisTile({
    super.key,
    required this.category,
    this.isFirst = false,
    this.isLast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedAmount = '${formatter.format(category.amount.round())} ₽';
    final formattedPercentage = '${category.percentage.toStringAsFixed(0)}%';

    String? subtitle;
    if (category.lastTransaction != null && category.lastTransaction!.comment != null) {
      subtitle = category.lastTransaction!.comment;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          if (isFirst) const Divider(height: 1),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              category.categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formattedPercentage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),
          if (!isLast) const Divider(height: 1),
          if (isLast) const Divider(height: 1),
        ],
      ),
    );
  }
} 