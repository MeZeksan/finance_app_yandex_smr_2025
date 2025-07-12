import 'package:finance_app_yandex_smr_2025/core/database/entities/transaction_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';

class DbTransactionRepository implements TransactionRepository {
  final DatabaseService _databaseService;

  DbTransactionRepository({required DatabaseService databaseService}) : _databaseService = databaseService;

  @override
  Future<TransactionResponce> addTransaction(TransactionRequest request) async {
    final now = DateTime.now();
    final transaction = TransactionEntity(
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: now,
      updatedAt: now,
    );
    
    // Устанавливаем связи
    transaction.accountId = request.accountId;
    transaction.categoryId = request.categoryId;
    
    final id = await _databaseService.addTransaction(transaction);
    
    // Получаем данные об аккаунте и категории для ответа
    final account = await _databaseService.getAccountById(request.accountId);
    final category = await _databaseService.getCategoryById(request.categoryId);
    
    if (account == null || category == null) {
      throw Exception('Account or category not found');
    }
    
    return TransactionResponce(
      id: id,
      account: AccountBrief(
        id: account.id,
        name: account.name,
        balance: account.balance,
        currency: account.currency,
      ),
      category: Category(
        id: category.id,
        name: category.name,
        emoji: category.emoji,
        isIncome: category.isIncome,
      ),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<bool> deleteTransaction(int transactionId) async {
    return await _databaseService.deleteTransaction(transactionId);
  }

  @override
  Future<TransactionResponce?> getTransactionById(int transactionId) async {
    final transaction = await _databaseService.getTransactionById(transactionId);
    if (transaction == null) return null;
    
    // Получаем данные об аккаунте и категории
    final account = await _databaseService.getAccountById(transaction.accountId);
    final category = await _databaseService.getCategoryById(transaction.categoryId);
    
    if (account == null || category == null) {
      throw Exception('Account or category not found');
    }
    
    return TransactionResponce(
      id: transaction.id,
      account: AccountBrief(
        id: account.id,
        name: account.name,
        balance: account.balance,
        currency: account.currency,
      ),
      category: Category(
        id: category.id,
        name: category.name,
        emoji: category.emoji,
        isIncome: category.isIncome,
      ),
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      comment: transaction.comment,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  @override
  Future<List<TransactionResponce>> getTransactionsByDateAndType({
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool isIncome,
  }) async {
    final transactions = await _databaseService.getTransactionsByDateRange(
      startDate: dateFrom,
      endDate: dateTo,
      isIncome: isIncome,
    );
    
    List<TransactionResponce> result = [];
    
    for (var transaction in transactions) {
      final account = await _databaseService.getAccountById(transaction.accountId);
      final category = await _databaseService.getCategoryById(transaction.categoryId);
      
      if (account != null && category != null) {
        result.add(
          TransactionResponce(
            id: transaction.id,
            account: AccountBrief(
              id: account.id,
              name: account.name,
              balance: account.balance,
              currency: account.currency,
            ),
            category: Category(
              id: category.id,
              name: category.name,
              emoji: category.emoji,
              isIncome: category.isIncome,
            ),
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment,
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt,
          ),
        );
      }
    }
    
    return result;
  }

  @override
  Future<TransactionResponce> updateTransaction(int transactionId, TransactionRequest request) async {
    final existingTransaction = await _databaseService.getTransactionById(transactionId);
    if (existingTransaction == null) {
      throw Exception('Transaction not found');
    }
    
    final updatedTransaction = TransactionEntity(
      id: transactionId,
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: existingTransaction.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Устанавливаем связи
    updatedTransaction.accountId = request.accountId;
    updatedTransaction.categoryId = request.categoryId;
    
    await _databaseService.addTransaction(updatedTransaction);
    
    // Получаем данные об аккаунте и категории для ответа
    final account = await _databaseService.getAccountById(request.accountId);
    final category = await _databaseService.getCategoryById(request.categoryId);
    
    if (account == null || category == null) {
      throw Exception('Account or category not found');
    }
    
    return TransactionResponce(
      id: transactionId,
      account: AccountBrief(
        id: account.id,
        name: account.name,
        balance: account.balance,
        currency: account.currency,
      ),
      category: Category(
        id: category.id,
        name: category.name,
        emoji: category.emoji,
        isIncome: category.isIncome,
      ),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: existingTransaction.createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 