import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  final TransactionResponce transaction;
  final bool showDate;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onChanged;

  const HistoryTile({
    super.key,
    required this.transaction,
    this.showDate = false,
    this.isFirst = false,
    this.isLast = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          final result = await TransactionScreen.show(
            context,
            transaction.category.isIncome,
            ServiceLocator.transactionRepository,
            transaction: transaction,
          );
          
          if (result == true && onChanged != null) {
            onChanged!();
          }
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: transaction.category.isIncome
                    ? Colors.green[100]
                    : Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  transaction.category.emoji,
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
                    transaction.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (transaction.comment?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.comment!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.category.isIncome ? '+' : '-'}${transaction.amount} ₽',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: transaction.category.isIncome
                        ? Colors.green[600]
                        : Colors.red[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.account.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Сегодня в ${_formatTime(date)}';
    } else if (transactionDate == yesterday) {
      return 'Вчера в ${_formatTime(date)}';
    } else {
      return '${_formatShortDate(date)} в ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }
}