import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/api_client.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/core/services/backup_service.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_create_request/account_create_request.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_history_responce/account_history_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_responce/account_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_update_request/account_update_request.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/stat_item/stat_item.dart';
import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/account_entity.dart';
import 'dart:developer' as developer;

class NetworkBankAccountRepository implements BankAccountRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final ApiClient _apiClient = ApiClient();
  final NetworkService _networkService = NetworkService();
  final BackupService _backupService = BackupService();

  @override
  Future<AccountResponce> getAccountById(int accountId) async {
    developer.log(
      '🔍 Получение счета по ID: $accountId',
      name: 'NetworkBankAccountRepository',
    );

    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация ожидающих операций', name: 'NetworkBankAccountRepository');
      await _backupService.syncPendingOperations();
    } else {
      developer.log('📵 Нет подключения к сети', name: 'NetworkBankAccountRepository');
    }

    // Ищем в локальной базе
    developer.log('💾 Поиск в локальной базе', name: 'NetworkBankAccountRepository');
    final localAccount = await _databaseService.getAccountById(accountId);
    if (localAccount != null) {
      developer.log('✅ Счет найден в локальной базе: ${localAccount.name}', name: 'NetworkBankAccountRepository');
      return await _mapEntityToResponse(localAccount);
    }

    developer.log('❌ Счет не найден в локальной базе', name: 'NetworkBankAccountRepository');

    // Если нет в локальной базе и есть сеть, запрашиваем с сервера
    if (_networkService.isConnected) {
      developer.log('🌐 Запрос счета с сервера: GET /accounts/$accountId', name: 'NetworkBankAccountRepository');
      try {
        final response = await _apiClient.get('/accounts/$accountId');
        if (response.statusCode == 200 && response.data != null) {
          final accountData = response.data as Map<String, dynamic>;
          final accountResponse = AccountResponce.fromJson(accountData);
          
          developer.log('✅ Счет получен с сервера: ${accountResponse.name}', name: 'NetworkBankAccountRepository');
          // Сохраняем в локальную базу
          await _saveAccountToLocal(accountResponse);
          return accountResponse;
        } else {
          developer.log('❌ Сервер вернул статус: ${response.statusCode}', name: 'NetworkBankAccountRepository');
        }
      } catch (e) {
        developer.log('❌ Ошибка при получении счета с сервера: $e', name: 'NetworkBankAccountRepository');
      }
    }

    // Проверяем, есть ли вообще какие-то счета в базе
    final allAccounts = await _databaseService.getAllAccounts();
    if (allAccounts.isNotEmpty) {
      // Возвращаем первый найденный счет
      developer.log('✅ Возвращаем первый доступный счет: ${allAccounts.first.name}', name: 'NetworkBankAccountRepository');
      return await _mapEntityToResponse(allAccounts.first);
    }

    // Если ничего не найдено, создаем дефолтный счет
    developer.log('💡 Создание дефолтного счета', name: 'NetworkBankAccountRepository');
    return await _createDefaultAccount(accountId);
  }

  // Создаем дефолтный счет если ничего не найдено
  Future<AccountResponce> _createDefaultAccount(int requestedAccountId) async {
    developer.log('🏗️ Создание дефолтного счета для ID: $requestedAccountId', name: 'NetworkBankAccountRepository');
    
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
    
    developer.log('✅ Дефолтный счет создан с фактическим ID: $actualId', name: 'NetworkBankAccountRepository');
    
    // Получаем созданный счет с правильным ID
    final savedAccount = await _databaseService.getAccountById(actualId);
    return await _mapEntityToResponse(savedAccount!);
  }

  @override
  Future<AccountResponce> updateAccount(
    int accountId,
    AccountUpdateRequest request,
  ) async {
    // Обновляем локально
    final existingAccount = await _databaseService.getAccountById(accountId);
    if (existingAccount == null) {
      throw Exception('Account not found');
    }
    
    final updatedAccount = AccountEntity(
      id: accountId,
      name: request.name,
      balance: request.balance,
      currency: request.currency,
      createdAt: existingAccount.createdAt,
      updatedAt: DateTime.now(),
    );
    
    await _databaseService.addAccount(updatedAccount);

    // Добавляем в бэкап для синхронизации
    await _backupService.addBackupOperation(
      operationType: BackupOperationType.update,
      dataType: BackupDataType.account,
      originalId: accountId,
      data: request.toJson(),
    );

    // Если есть сеть, пытаемся сразу синхронизировать
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
    }

    // Возвращаем обновленные данные
    return await _mapEntityToResponse(updatedAccount);
  }

  // Дополнительные методы для полноценной работы с API
  Future<List<AccountBrief>> getAllAccounts() async {
    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
      
      // Пытаемся загрузить с сервера
      try {
        final response = await _apiClient.get('/accounts');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final accounts = (data['data'] as List)
              .map((json) => AccountResponce.fromJson(json))
              .toList();
          
          // Обновляем локальную базу
          await _updateLocalAccounts(accounts);
          return accounts.map(_mapResponseToBrief).toList();
        }
      } catch (e) {
        print('Error fetching accounts from server: $e');
      }
    }

    // Возвращаем данные из локальной базы
    final localAccounts = await _databaseService.getAllAccounts();
    return localAccounts.map(_mapEntityToBrief).toList();
  }

  Future<AccountResponce> createAccount(AccountCreateRequest request) async {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    
    // Создаем временный аккаунт локально
    final now = DateTime.now();
    final localAccount = AccountEntity(
      id: tempId,
      name: request.name,
      balance: request.balance,
      currency: request.currency,
      createdAt: now,
      updatedAt: now,
    );
    
    final localId = await _databaseService.addAccount(localAccount);
    
    // Добавляем в бэкап для синхронизации
    await _backupService.addBackupOperation(
      operationType: BackupOperationType.create,
      dataType: BackupDataType.account,
      originalId: localId,
      data: request.toJson(),
    );

    // Если есть сеть, пытаемся сразу синхронизировать
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
    }

    // Возвращаем ответ на основе локальных данных
    final savedAccount = await _databaseService.getAccountById(localId);
    return await _mapEntityToResponse(savedAccount!);
  }

  Future<bool> deleteAccount(int accountId) async {
    // Удаляем локально
    final deleted = await _databaseService.deleteAccount(accountId);
    
    if (deleted) {
      // Добавляем в бэкап для синхронизации
      await _backupService.addBackupOperation(
        operationType: BackupOperationType.delete,
        dataType: BackupDataType.account,
        originalId: accountId,
        data: {'id': accountId},
      );

      // Если есть сеть, пытаемся сразу синхронизировать
      if (_networkService.isConnected) {
        await _backupService.syncPendingOperations();
      }
    }
    
    return deleted;
  }

  Future<AccountHistoryResponce> getHistory(int accountId) async {
    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
      
      // Пытаемся загрузить с сервера
      try {
        final response = await _apiClient.get('/accounts/$accountId/history');
        if (response.statusCode == 200 && response.data != null) {
          final historyData = response.data as Map<String, dynamic>;
          return AccountHistoryResponce.fromJson(historyData);
        }
      } catch (e) {
        print('Error fetching account history from server: $e');
      }
    }

    // Возвращаем базовую историю из локальной базы
    final account = await _databaseService.getAccountById(accountId);
    if (account == null) {
      throw Exception('Account not found');
    }

    // Создаем простую историю для демонстрации
    return AccountHistoryResponce(
      accountId: accountId,
      accountName: account.name,
      currency: account.currency,
      currentBalance: account.balance,
      history: _createMockHistory(account),
    );
  }

  // Вспомогательные методы для маппинга данных
  Future<AccountResponce> _mapEntityToResponse(AccountEntity entity) async {
    // Создаем базовые статистики (в реальном API они должны приходить с сервера)
    final incomeStats = StatItem(
      categoryId: 1,
      categoryName: 'Доходы',
      emoji: '💰',
      amount: '0.00',
    );
    
    final expenseStats = StatItem(
      categoryId: 2,
      categoryName: 'Расходы',
      emoji: '💸',
      amount: '0.00',
    );

    return AccountResponce(
      id: entity.id,
      name: entity.name,
      balance: entity.balance,
      currency: entity.currency,
      incomeStats: incomeStats,
      expenseStats: expenseStats,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AccountBrief _mapEntityToBrief(AccountEntity entity) {
    return AccountBrief(
      id: entity.id,
      name: entity.name,
      balance: entity.balance,
      currency: entity.currency,
    );
  }

  AccountBrief _mapResponseToBrief(AccountResponce response) {
    return AccountBrief(
      id: response.id,
      name: response.name,
      balance: response.balance,
      currency: response.currency,
    );
  }

  Future<void> _saveAccountToLocal(AccountResponce account) async {
    final entity = AccountEntity(
      id: account.id,
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
    
    await _databaseService.addAccount(entity);
  }

  Future<void> _updateLocalAccounts(List<AccountResponce> accounts) async {
    for (final account in accounts) {
      await _saveAccountToLocal(account);
    }
  }

  dynamic _createMockHistory(AccountEntity account) {
    // Создаем простую историю для демонстрации
    // В реальном приложении это должно быть более сложной структурой
    return {
      'id': 1,
      'accountId': account.id,
      'changeType': 'MODIFICATION',
      'previousState': {
        'id': 0,
        'name': account.name,
        'balance': '0.00',
        'currency': account.currency,
      },
      'newState': {
        'id': 1,
        'name': account.name,
        'balance': account.balance,
        'currency': account.currency,
      },
      'changeTimestamp': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
} 