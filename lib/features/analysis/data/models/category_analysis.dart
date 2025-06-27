import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';

class CategoryAnalysis {
  final String categoryId;
  final String categoryName;
  final String emoji;
  final double amount;
  final double percentage;
  final List<TransactionResponce> transactions;
  final TransactionResponce? lastTransaction;

  CategoryAnalysis({
    required this.categoryId,
    required this.categoryName,
    required this.emoji,
    required this.amount,
    required this.percentage,
    required this.transactions,
  }) : lastTransaction = transactions.isNotEmpty ? transactions.first : null;
} 