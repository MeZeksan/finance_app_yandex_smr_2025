import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';

abstract class TransactionRepository {
  Future<TransactionResponce?> getTransactionById(int transactionId);

  Future<TransactionResponce> addTransaction(TransactionRequest request);

  Future<TransactionResponce> updateTransaction(
      int transactionId, TransactionRequest request);

  Future<bool> deleteTransaction(int transactionId);

  Future<List<TransactionResponce>> getTransactionsByDateAndType({
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool isIncome,
  });

}
