import 'dart:async';

import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final Map<int, TransactionResponce> _transactions = {};
  int _nextId = 1;

  MockTransactionRepository() {
    _initializeWithMockData();
  }

  void _initializeWithMockData() {
    _transactions[1] = TransactionResponce(
      id: 1,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        balance: '24334',
        currency: 'RUB',
      ),
      category: Category(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
      amount: '50000.00',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      comment: 'Зарплата за месяц',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    _transactions[2] = TransactionResponce(
      id: 2,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '34356',
      ),
      category: Category(id: 2, name: 'Продукты', emoji: '🛒', isIncome: false),
      amount: '2500.50',
      transactionDate: DateTime.now().subtract(const Duration(hours: 6)),
      comment: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    );

    _nextId = 3;
  }

  @override
  Future<TransactionResponce?> getTransactionById(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions[transactionId];
  }

  @override
  Future<TransactionResponce> addTransaction(TransactionRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final newTransaction = TransactionResponce(
      id: _nextId++,
      account: AccountBrief(
          id: request.accountId,
          name: 'Счет ${request.accountId}',
          currency: 'RUB',
          balance: '00.00'),
      category: Category(
          id: request.categoryId,
          name: 'Категория ${request.categoryId}',
          emoji: '📊',
          isIncome: true),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: now,
      updatedAt: now,
    );

    _transactions[newTransaction.id] = newTransaction;
    return newTransaction;
  }

  @override
  Future<TransactionResponce> updateTransaction(
    int transactionId,
    TransactionRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final existingTransaction = _transactions[transactionId];
    if (existingTransaction == null) {
      throw Exception('Transaction with id $transactionId not found');
    }

    final updatedTransaction = existingTransaction.copyWith(
      account: AccountBrief(
          id: request.accountId,
          name: 'Счет ${request.accountId}',
          currency: 'RUB',
          balance: '23560.00'),
      category: Category(
          id: request.categoryId,
          name: 'Категория ${request.categoryId}',
          emoji: '📊',
          isIncome: false),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      updatedAt: DateTime.now(),
    );

    _transactions[transactionId] = updatedTransaction;
    return updatedTransaction;
  }

  @override
  Future<bool> deleteTransaction(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final removed = _transactions.remove(transactionId);
    return removed != null;
  }
}
