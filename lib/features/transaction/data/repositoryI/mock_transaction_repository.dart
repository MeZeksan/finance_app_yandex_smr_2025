import 'dart:async';

import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final Map<int, TransactionResponce> _transactions = {};
  int _nextId = 1;

  // Список категорий расходов с эмодзи
  final List<(String, String)> _expenseCategories = [
    ('Комикс-шоп', '📚'),
    ('Зоомагазин', '🐾'),
    ('Кофейня', '☕'),
    ('Кинотеатр', '🎬'),
    ('Книжный', '📖'),
    ('Игровой магазин', '🎮'),
    ('Пиццерия', '🍕'),
    ('Суши-бар', '🍱'),
    ('Спортзал', '🏋️'),
    ('Магазин музыки', '🎵'),
  ];

  // Список категорий доходов с эмодзи
  final List<(String, String)> _incomeCategories = [
    ('Зарплата', '💰'),
    ('Фриланс', '💻'),
    ('Инвестиции', '📈'),
    ('Подработка', '💼'),
  ];

  MockTransactionRepository() {
    _initializeWithMockData();
  }

  void _initializeWithMockData() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    var currentBalance = 0.0; // Начинаем с нулевого баланса
    
    // Генерируем транзакции за весь месяц
    for (int day = 1; day <= lastDayOfMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final isIncome = day % 6 == 0 || day % 9 == 0; // Те же условия, что и в BalanceData
      
      // Генерируем сумму транзакции
      final base = isIncome ? 35000.0 : 12000.0;
      final variation = isIncome ? 20000.0 : 15000.0;
      final mod = (day % 8) - 4;
      final amount = base + variation * mod.abs() / 4;
      
      // Выбираем случайную категорию из соответствующего списка
      final categoryIndex = day % (isIncome ? _incomeCategories.length : _expenseCategories.length);
      final (categoryName, categoryEmoji) = isIncome 
          ? _incomeCategories[categoryIndex]
          : _expenseCategories[categoryIndex];
      
      // Создаем категорию
      final category = Category(
        id: _nextId,
        name: categoryName,
        emoji: categoryEmoji,
        isIncome: isIncome,
      );
      
      // Обновляем баланс (доходы добавляем, расходы вычитаем)
      if (isIncome) {
        currentBalance += amount;
      } else {
        currentBalance -= amount;
      }
      
      // Создаем комментарий в зависимости от категории
      String? comment;
      if (!isIncome) {
        switch (categoryName) {
          case 'Комикс-шоп':
            comment = 'Новый выпуск Человека-паука';
            break;
          case 'Зоомагазин':
            comment = 'Корм и игрушки для питомца';
            break;
          case 'Кофейня':
            comment = 'Латте и круассан';
            break;
          case 'Кинотеатр':
            comment = 'Билеты на премьеру';
            break;
          case 'Книжный':
            comment = 'Новинки фантастики';
            break;
          case 'Игровой магазин':
            comment = 'Предзаказ новой игры';
            break;
          case 'Пиццерия':
            comment = 'Пицца с друзьями';
            break;
          case 'Суши-бар':
            comment = 'Роллы на ужин';
            break;
          case 'Спортзал':
            comment = 'Месячный абонемент';
            break;
          case 'Магазин музыки':
            comment = 'Виниловые пластинки';
            break;
        }
      } else {
        switch (categoryName) {
          case 'Зарплата':
            comment = 'Ежемесячная зарплата';
            break;
          case 'Фриланс':
            comment = 'Завершение проекта';
            break;
          case 'Инвестиции':
            comment = 'Дивиденды';
            break;
          case 'Подработка':
            comment = 'Дополнительная работа';
            break;
        }
      }
      
      // Создаем транзакцию
      _transactions[_nextId] = TransactionResponce(
        id: _nextId,
        account: AccountBrief(
          id: 1,
          name: 'Основной счет',
          balance: currentBalance.toStringAsFixed(2),
          currency: 'RUB',
        ),
        category: category,
        amount: amount.toStringAsFixed(2),
        transactionDate: date.add(Duration(hours: 9 + day % 12)), // Разное время в течение дня
        comment: comment,
        createdAt: date,
        updatedAt: date,
      );
      
      _nextId++;
    }
  }

  @override
  Future<TransactionResponce?> getTransactionById(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions[transactionId];
  }

  Future<List<TransactionResponce>> getAllTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.values.toList();
  }

  Future<List<TransactionResponce>> getTransactionsByDateAndType({
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool isIncome,
  }) async {
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
          balance: '0.00'),
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
          balance: existingTransaction.account.balance),
      category: Category(
          id: request.categoryId,
          name: 'Категория ${request.categoryId}',
          emoji: '📊',
          isIncome: existingTransaction.category.isIncome),
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