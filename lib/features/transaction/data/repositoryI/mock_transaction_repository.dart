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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Доходы за сегодня
    _transactions[1] = TransactionResponce(
      id: 1,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        balance: '524334',
        currency: 'RUB',
      ),
      category: Category(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
      amount: '500000.00',
      transactionDate: today.add(const Duration(hours: 9)),
      comment: 'Зарплата за месяц',
      createdAt: today.add(const Duration(hours: 9)),
      updatedAt: today.add(const Duration(hours: 9)),
    );

    _transactions[2] = TransactionResponce(
      id: 2,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '624334',
      ),
      category: Category(id: 2, name: 'Подработка', emoji: '💼', isIncome: true),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 15)),
      comment: 'Фриланс проект',
      createdAt: today.add(const Duration(hours: 15)),
      updatedAt: today.add(const Duration(hours: 15)),
    );

    // Расходы за сегодня
    _transactions[3] = TransactionResponce(
      id: 3,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '524334',
      ),
      category: Category(id: 3, name: 'Аренда квартиры', emoji: '🏠', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 10)),
      comment: null,
      createdAt: today.add(const Duration(hours: 10)),
      updatedAt: today.add(const Duration(hours: 10)),
    );

    _transactions[4] = TransactionResponce(
      id: 4,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '424334',
      ),
      category: Category(id: 4, name: 'Одежда', emoji: '👕', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 12)),
      comment: null,
      createdAt: today.add(const Duration(hours: 12)),
      updatedAt: today.add(const Duration(hours: 12)),
    );

    _transactions[5] = TransactionResponce(
      id: 5,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '324334',
      ),
      category: Category(id: 5, name: 'На собачку', emoji: '🐕', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 14)),
      comment: 'Джек',
      createdAt: today.add(const Duration(hours: 14)),
      updatedAt: today.add(const Duration(hours: 14)),
    );

    _transactions[6] = TransactionResponce(
      id: 6,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '224334',
      ),
      category: Category(id: 6, name: 'На собачку', emoji: '🐕', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 16)),
      comment: 'Энни',
      createdAt: today.add(const Duration(hours: 16)),
      updatedAt: today.add(const Duration(hours: 16)),
    );

    _transactions[7] = TransactionResponce(
      id: 7,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '124334',
      ),
      category: Category(id: 7, name: 'Ремонт квартиры', emoji: '🔨', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 18)),
      comment: null,
      createdAt: today.add(const Duration(hours: 18)),
      updatedAt: today.add(const Duration(hours: 18)),
    );

    _transactions[8] = TransactionResponce(
      id: 8,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '24334',
      ),
      category: Category(id: 8, name: 'Продукты', emoji: '🛒', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 19)),
      comment: null,
      createdAt: today.add(const Duration(hours: 19)),
      updatedAt: today.add(const Duration(hours: 19)),
    );

    _transactions[9] = TransactionResponce(
      id: 9,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '0',
      ),
      category: Category(id: 9, name: 'Спортзал', emoji: '🏋️', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 20)),
      comment: null,
      createdAt: today.add(const Duration(hours: 20)),
      updatedAt: today.add(const Duration(hours: 20)),
    );

    _transactions[10] = TransactionResponce(
      id: 10,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '0',
      ),
      category: Category(id: 10, name: 'Медицина', emoji: '💊', isIncome: false),
      amount: '100000.00',
      transactionDate: today.add(const Duration(hours: 21)),
      comment: null,
      createdAt: today.add(const Duration(hours: 21)),
      updatedAt: today.add(const Duration(hours: 21)),
    );

    _transactions[11] = TransactionResponce(
      id: 11,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '0',
      ),
      category: Category(id: 11, name: 'Праздник', emoji: '🎂', isIncome: false),
      amount: '200000.00',
      transactionDate: today.add(const Duration(hours: 36)),
      comment: null,
      createdAt: today.add(const Duration(hours: 36)),
      updatedAt: today.add(const Duration(hours: 36)),
    );
  }

  @override
  Future<TransactionResponce?> getTransactionById(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions[transactionId];
  }

  // Новый метод для получения всех транзакций
  Future<List<TransactionResponce>> getAllTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.values.toList();
  }

  Future<List<TransactionResponce>> getTransactionsByDateAndType({
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool isIncome,
  }) async {
    // Ваша существующая реализация уже корректна
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _transactions.values.where((transaction) {
      final isInDateRange = transaction.transactionDate.isAfter(dateFrom.subtract(const Duration(seconds: 1))) &&
          transaction.transactionDate.isBefore(dateTo.add(const Duration(seconds: 1)));
      final isCorrectType = transaction.category.isIncome == isIncome;
      return isInDateRange && isCorrectType;
    }).toList();
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