import 'package:finance_app_yandex_smr_2025/features/analysis/data/models/category_analysis.dart';
import 'package:finance_app_yandex_smr_2025/features/history/presentation/widgets/history_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  final CategoryAnalysis category;

  const CategoryTransactionsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;
    
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedAmount = '${formatter.format(category.amount.round())} ₽';
    final formattedPercentage = '${category.percentage.toStringAsFixed(0)}%';

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFb2AE881),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    category.categoryName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF1D1B20),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFD4FAE6),
            ),
            child: Row(
              children: [
                Container(
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.categoryName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Всего: $formattedAmount ($formattedPercentage)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Transactions List
          Expanded(
            child: category.transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет транзакций',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: category.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = category.transactions[index];
                      return HistoryTile(
                        transaction: transaction,
                        showDate: true,
                        isFirst: index == 0,
                        isLast: index == category.transactions.length - 1,
                        onChanged: () {
                          // Pop back to refresh the analysis screen
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 