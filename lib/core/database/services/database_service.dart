import 'package:finance_app_yandex_smr_2025/core/database/entities/account_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/transaction_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/objectbox.dart';
import 'package:finance_app_yandex_smr_2025/objectbox.g.dart';

class DatabaseService {
  late final ObjectBox _objectBox;

  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();

  static DatabaseService get instance => _instance;

  bool _isInitialized = false;

  ObjectBox get objectBox => _objectBox;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _objectBox = await ObjectBox.create();
    _isInitialized = true;
  }

  // Account methods
  Future<List<AccountEntity>> getAllAccounts() async {
    return _objectBox.accountBox.getAll();
  }

  Future<AccountEntity?> getAccountById(int id) async {
    return _objectBox.accountBox.get(id);
  }

  Future<int> addAccount(AccountEntity account) async {
    return _objectBox.accountBox.put(account);
  }

  Future<bool> deleteAccount(int id) async {
    return _objectBox.accountBox.remove(id);
  }

  // Category methods
  Future<List<CategoryEntity>> getAllCategories() async {
    return _objectBox.categoryBox.getAll();
  }

  Future<List<CategoryEntity>> getCategoriesByType(bool isIncome) async {
    final query = _objectBox.categoryBox.query(CategoryEntity_.isIncome.equals(isIncome)).build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  Future<CategoryEntity?> getCategoryById(int id) async {
    return _objectBox.categoryBox.get(id);
  }

  Future<int> addCategory(CategoryEntity category) async {
    return _objectBox.categoryBox.put(category);
  }

  Future<bool> deleteCategory(int id) async {
    return _objectBox.categoryBox.remove(id);
  }

  // Transaction methods
  Future<List<TransactionEntity>> getAllTransactions() async {
    final transactions = _objectBox.transactionBox.getAll();
    // Инициализируем ToOne отношения для всех транзакций
    for (final transaction in transactions) {
      transaction.account.attach(_objectBox.store);
      transaction.category.attach(_objectBox.store);
    }
    return transactions;
  }

  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    bool? isIncome,
  }) async {
    final query = _objectBox.transactionBox
        .query(TransactionEntity_.transactionDate
            .between(startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch))
        .build();
    
    try {
      final transactions = query.find();
      
      // Инициализируем ToOne отношения для всех транзакций
      for (final transaction in transactions) {
        transaction.account.attach(_objectBox.store);
        transaction.category.attach(_objectBox.store);
      }
      
      if (isIncome != null) {
        // Фильтрация по типу (доход/расход) через связанные категории
        return transactions.where((transaction) {
          final category = transaction.category.target;
          return category != null && category.isIncome == isIncome;
        }).toList();
      }
      
      return transactions;
    } finally {
      query.close();
    }
  }

  Future<TransactionEntity?> getTransactionById(int id) async {
    final transaction = _objectBox.transactionBox.get(id);
    if (transaction != null) {
      // Инициализируем ToOne отношения
      transaction.account.attach(_objectBox.store);
      transaction.category.attach(_objectBox.store);
    }
    return transaction;
  }

  Future<int> addTransaction(TransactionEntity transaction) async {
    // Инициализируем ToOne отношения перед сохранением
    transaction.account.attach(_objectBox.store);
    transaction.category.attach(_objectBox.store);
    
    // Устанавливаем targetId если они не установлены
    if (transaction.accountId > 0) {
      transaction.account.targetId = transaction.accountId;
    }
    if (transaction.categoryId > 0) {
      transaction.category.targetId = transaction.categoryId;
    }
    
    return _objectBox.transactionBox.put(transaction);
  }

  Future<bool> deleteTransaction(int id) async {
    return _objectBox.transactionBox.remove(id);
  }

  void close() {
    if (_isInitialized) {
      _objectBox.close();
    }
  }
} 