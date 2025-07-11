import 'package:finance_app_yandex_smr_2025/core/database/entities/account_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account/account.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_create_request/account_create_request.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_history.dart/account_history.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_history_responce/account_history_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_responce/account_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_state/account_state.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_update_request/account_update_request.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/stat_item/stat_item.dart';
import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';

class DbAccountRepository implements BankAccountRepository {
  final DatabaseService _databaseService;

  DbAccountRepository({required DatabaseService databaseService}) : _databaseService = databaseService;

  // Конвертация между Entity и моделью
  AccountEntity _mapToEntity(Account account) {
    return AccountEntity(
      id: account.id,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  Account _mapFromEntity(AccountEntity entity) {
    return Account(
      id: entity.id,
      userId: 1, // Используем фиксированное значение для userId
      name: entity.name,
      balance: entity.balance,
      currency: entity.currency,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AccountBrief _mapToBrief(AccountEntity entity) {
    return AccountBrief(
      id: entity.id,
      name: entity.name,
      balance: entity.balance,
      currency: entity.currency,
    );
  }

  Future<AccountResponce> createAccount(AccountCreateRequest request) async {
    final now = DateTime.now();
    final account = AccountEntity(
      name: request.name,
      balance: '0',
      currency: request.currency,
      createdAt: now,
      updatedAt: now,
    );
    
    final id = await _databaseService.addAccount(account);
    
    // Создаем пустые статистики для нового аккаунта
    final emptyIncomeStats = StatItem(
      categoryId: 0,
      categoryName: 'Доходы',
      emoji: '📈',
      amount: '0',
    );
    
    final emptyExpenseStats = StatItem(
      categoryId: 0,
      categoryName: 'Расходы',
      emoji: '📉',
      amount: '0',
    );
    
    return AccountResponce(
      id: id,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      incomeStats: emptyIncomeStats,
      expenseStats: emptyExpenseStats,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  Future<bool> deleteAccount(int accountId) async {
    return await _databaseService.deleteAccount(accountId);
  }

  Future<List<AccountBrief>> getAllAccounts() async {
    final accounts = await _databaseService.getAllAccounts();
    return accounts.map(_mapToBrief).toList();
  }

  Future<AccountHistoryResponce> getHistory(int accountId) async {
    // Получаем аккаунт из БД
    final account = await _databaseService.getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }
    
    // Создаем пустую историю для демонстрации
    final now = DateTime.now();
    final previousState = AccountState(
      id: 0,
      name: account.name,
      balance: '0',
      currency: account.currency,
    );
    
    final newState = AccountState(
      id: 1,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
    );
    
    final history = AccountHistory(
      id: 1,
      accountId: accountId,
      changeType: 'MODIFICATION',
      previousState: previousState,
      newState: newState,
      changeTimestamp: now,
      createdAt: now,
    );
    
    return AccountHistoryResponce(
      accountId: accountId,
      accountName: account.name,
      currency: account.currency,
      currentBalance: account.balance,
      history: history,
    );
  }

  Future<AccountResponce> getAccountById(int accountId) async {
    final entity = await _databaseService.getAccountById(accountId);
    
    // Если счет найден, возвращаем его
    if (entity != null) {
      return _mapEntityToResponse(entity);
    }
    
    // Проверяем, есть ли вообще какие-то счета в базе
    final allAccounts = await _databaseService.getAllAccounts();
    if (allAccounts.isNotEmpty) {
      // Возвращаем первый найденный счет
      return _mapEntityToResponse(allAccounts.first);
    }
    
    // Если счет не найден и база пуста, создаем дефолтный
    final now = DateTime.now();
    final defaultAccount = AccountEntity(
      id: 0, // Используем 0 для автогенерации ID в ObjectBox
      name: 'Основной счет',
      balance: '0.00',
      currency: 'RUB',
      createdAt: now,
      updatedAt: now,
    );
    
    // Сохраняем в локальную базу - ObjectBox автоматически присвоит ID
    final actualId = await _databaseService.addAccount(defaultAccount);
    
    // Получаем созданный счет с правильным ID
    final savedAccount = await _databaseService.getAccountById(actualId);
    return _mapEntityToResponse(savedAccount!);
  }

  // Вспомогательный метод для маппинга сущности в ответ
  AccountResponce _mapEntityToResponse(AccountEntity entity) {
    // Создаем базовые статистики для демонстрации
    final emptyIncomeStats = StatItem(
      categoryId: 0,
      categoryName: 'Доходы',
      emoji: '📈',
      amount: '0.00',
    );
    
    final emptyExpenseStats = StatItem(
      categoryId: 0,
      categoryName: 'Расходы',
      emoji: '📉',
      amount: '0.00',
    );
    
    return AccountResponce(
      id: entity.id,
      name: entity.name,
      balance: entity.balance,
      currency: entity.currency,
      incomeStats: emptyIncomeStats,
      expenseStats: emptyExpenseStats,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  Future<AccountResponce> updateAccount(int accountId, AccountUpdateRequest request) async {
    final existingAccount = await _databaseService.getAccountById(accountId);
    if (existingAccount == null) {
      throw Exception('Account not found');
    }
    
    final updatedAccount = AccountEntity(
      id: accountId,
      name: request.name ?? existingAccount.name,
      balance: request.balance ?? existingAccount.balance,
      currency: request.currency ?? existingAccount.currency,
      createdAt: existingAccount.createdAt,
      updatedAt: DateTime.now(),
    );
    
    await _databaseService.addAccount(updatedAccount);
    
    // Создаем пустые статистики для демонстрации
    final emptyIncomeStats = StatItem(
      categoryId: 0,
      categoryName: 'Доходы',
      emoji: '📈',
      amount: '0',
    );
    
    final emptyExpenseStats = StatItem(
      categoryId: 0,
      categoryName: 'Расходы',
      emoji: '📉',
      amount: '0',
    );
    
    return AccountResponce(
      id: updatedAccount.id,
      name: updatedAccount.name,
      balance: updatedAccount.balance,
      currency: updatedAccount.currency,
      incomeStats: emptyIncomeStats,
      expenseStats: emptyExpenseStats,
      createdAt: updatedAccount.createdAt,
      updatedAt: updatedAccount.updatedAt,
    );
  }
} 