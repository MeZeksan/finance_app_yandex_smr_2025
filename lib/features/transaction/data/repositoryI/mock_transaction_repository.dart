import 'dart:async';

import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  static final MockTransactionRepository _instance = MockTransactionRepository._internal();
  static MockTransactionRepository get instance => _instance;
  
  final Map<int, TransactionResponce> _transactions = {};
  int _nextId = 1;
  double _currentBalance = 0.0;

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

  MockTransactionRepository._internal() {
    _initializeWithMockData();
  }
  
  factory MockTransactionRepository() => _instance;

  // Находим категорию по ID, возвращаем (name, emoji, isIncome)
  (String, String, bool)? _findCategoryById(int categoryId) {
    // Проверяем категории доходов
    for (int i = 0; i < _incomeCategories.length; i++) {
      if (categoryId == i + 1) { // ID начинаются с 1
        return (_incomeCategories[i].$1, _incomeCategories[i].$2, true);
      }
    }
    
    // Проверяем категории расходов
    for (int i = 0; i < _expenseCategories.length; i++) {
      if (categoryId == i + 5) { // ID расходов начинаются с 5
        return (_expenseCategories[i].$1, _expenseCategories[i].$2, false);
      }
    }
    
    return null;
  }

  void _updateBalance(double amount, bool isIncome, {bool isAdding = true}) {
    if (isAdding) {
      // Добавляем транзакцию
      if (isIncome) {
        _currentBalance += amount;
      } else {
        _currentBalance -= amount;
      }
    } else {
      // Удаляем транзакцию
      if (isIncome) {
        _currentBalance -= amount;
      } else {
        _currentBalance += amount;
      }
    }
  }

  void _updateAllAccountBalances() {
    // Обновляем баланс во всех транзакциях
    for (final transaction in _transactions.values) {
      final updatedAccount = AccountBrief(
        id: transaction.account.id,
        name: transaction.account.name,
        balance: _currentBalance.toStringAsFixed(2),
        currency: transaction.account.currency,
      );
      
      _transactions[transaction.id] = transaction.copyWith(account: updatedAccount);
    }
  }

  void _initializeWithMockData() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    _currentBalance = 0.0; // Начинаем с нулевого баланса
    
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
        _currentBalance += amount;
      } else {
        _currentBalance -= amount;
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
          balance: _currentBalance.toStringAsFixed(2),
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

    // Находим реальную категорию по ID
    final categoryData = _findCategoryById(request.categoryId);
    if (categoryData == null) {
      throw Exception('Category with id ${request.categoryId} not found');
    }

    final now = DateTime.now();
    // Обновляем баланс
    final amount = double.parse(request.amount);
    _updateBalance(amount, categoryData.$3);

    final newTransaction = TransactionResponce(
      id: _nextId++,
      account: AccountBrief(
        id: request.accountId,
        name: 'Основной счет',
        currency: 'RUB',
        balance: _currentBalance.toStringAsFixed(2),
      ),
      category: Category(
        id: request.categoryId,
        name: categoryData.$1,
        emoji: categoryData.$2,
        isIncome: categoryData.$3,
      ),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: now,
      updatedAt: now,
    );

    _transactions[newTransaction.id] = newTransaction;
    
    // Обновляем баланс во всех существующих транзакциях
    _updateAllAccountBalances();
    
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

    // Находим реальную категорию по ID
    final categoryData = _findCategoryById(request.categoryId);
    if (categoryData == null) {
      throw Exception('Category with id ${request.categoryId} not found');
    }

    // Откатываем старую транзакцию и добавляем новую
    final oldAmount = double.parse(existingTransaction.amount);
    final newAmount = double.parse(request.amount);
    
    // Откатываем старую транзакцию
    _updateBalance(oldAmount, existingTransaction.category.isIncome, isAdding: false);
    
    // Добавляем новую транзакцию
    _updateBalance(newAmount, categoryData.$3, isAdding: true);

    final updatedTransaction = existingTransaction.copyWith(
      account: AccountBrief(
        id: request.accountId,
        name: 'Основной счет',
        currency: 'RUB',
        balance: _currentBalance.toStringAsFixed(2),
      ),
      category: Category(
        id: request.categoryId,
        name: categoryData.$1,
        emoji: categoryData.$2,
        isIncome: categoryData.$3,
      ),
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      updatedAt: DateTime.now(),
    );

    _transactions[transactionId] = updatedTransaction;
    
    // Обновляем баланс во всех транзакциях
    _updateAllAccountBalances();
    
    return updatedTransaction;
  }

  @override
  Future<bool> deleteTransaction(int transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final transaction = _transactions[transactionId];
    if (transaction != null) {
      // Откатываем баланс
      final amount = double.parse(transaction.amount);
      _updateBalance(amount, transaction.category.isIncome, isAdding: false);
      
      // Удаляем транзакцию
      _transactions.remove(transactionId);
      
      // Обновляем баланс во всех оставшихся транзакциях
      _updateAllAccountBalances();
      
      return true;
    }
    
    return false;
  }
}