
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionResponce transaction;
  final bool isFirst;
  final bool isLast;

  const TransactionTile({
    super.key,
    required this.transaction, required this.isFirst, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(transaction.amount) ?? 0.0;
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedAmount = '${formatter.format(amount.round())} ₽';
    

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7FF),
      ),
      child: Column(
        children: [
          if (isFirst) const Divider(height: 0,),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () {
              // TODO: Навигация к детальному просмотру транзакции
            },
          ),
          if (!isLast) const Divider(height: 0,),
        if (isLast) const Divider(height: 0,),
          ],
      ),
    );
  }
}