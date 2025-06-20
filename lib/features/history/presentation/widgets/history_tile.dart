
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryTile extends StatelessWidget {
  final TransactionResponce transaction;
  final bool showDate;
  final bool isFirst;
  final bool isLast;

  const HistoryTile({
    super.key,
    required this.transaction,
    this.showDate = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(transaction.amount) ?? 0.0;
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedAmount = '${formatter.format(amount.round())} ₽';

    // Use safe formatters that don't require locale initialization
    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final timeString = timeFormatter.format(transaction.transactionDate);
    final dateString = dateFormatter.format(transaction.transactionDate);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEF7FF),
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
                color: const Color(0xFFFEF7FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  transaction.category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (transaction.comment != null && transaction.comment!.isNotEmpty)
                  Text(
                    transaction.comment!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
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
                  showDate ? '$dateString $timeString' : timeString,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Навигация к детальному просмотру транзакции
            },
          ),
          if (!isLast) const Divider(height: 1),
          if (isLast) const Divider(height: 1),
        ],
      ),
    );
  }
}