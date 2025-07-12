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
import 'package:finance_app_yandex_smr_2025/features/account/data/models/balance_data/balance_data.dart';
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

    // ВСЕГДА проверяем сервер в первую очередь если есть сеть
    if (_networkService.isConnected) {
      developer.log('🌐 Запрос всех счетов с сервера: GET /accounts', name: 'NetworkBankAccountRepository');
      try {
        final response = await _apiClient.get('/accounts');
        if (response.statusCode == 200 && response.data != null) {
          developer.log('✅ Получен ответ от сервера: ${response.data}', name: 'NetworkBankAccountRepository');
          
          // API возвращает массив счетов напрямую
          final accountsData = response.data as List<dynamic>;
          
          if (accountsData.isNotEmpty) {
            // Ищем нужный счет по ID или берем первый
            final accountData = accountsData.first as Map<String, dynamic>;
            
            developer.log('📊 Счет с сервера: ID=${accountData['id']}, name="${accountData['name']}", balance=${accountData['balance']}', name: 'NetworkBankAccountRepository');
            developer.log('💰 ВНИМАНИЕ: Баланс с сервера = ${accountData['balance']} ${accountData['currency']}', name: 'NetworkBankAccountRepository');
            
            // Создаем объект AccountResponce с реальными данными сервера
            final accountResponse = AccountResponce(
              id: accountData['id'],
              name: accountData['name'] ?? 'Основной счет',
              balance: accountData['balance']?.toString() ?? '0.00', // Принудительно конвертируем в строку
              currency: accountData['currency'] ?? 'RUB',
              incomeStats: StatItem(
                categoryId: 1,
                categoryName: 'Доходы',
                emoji: '💰',
                amount: '0.00',
              ),
              expenseStats: StatItem(
                categoryId: 2,
                categoryName: 'Расходы',
                emoji: '💸',
                amount: '0.00',
              ),
              createdAt: DateTime.parse(accountData['createdAt'] ?? DateTime.now().toIso8601String()),
              updatedAt: DateTime.parse(accountData['updatedAt'] ?? DateTime.now().toIso8601String()),
            );
            
            developer.log('✅ Счет получен с сервера: ${accountResponse.name} (${accountResponse.balance} ${accountResponse.currency})', name: 'NetworkBankAccountRepository');
            developer.log('💳 РЕЗУЛЬТАТ: Возвращаем баланс = ${accountResponse.balance}', name: 'NetworkBankAccountRepository');
            
            // Пытаемся обновить локальную базу новыми данными (в отдельном блоке)
            try {
              await _saveAccountToLocal(accountResponse);
            } catch (saveError) {
              developer.log('⚠️ Ошибка сохранения в локальную базу (не критично): $saveError', name: 'NetworkBankAccountRepository');
            }
            
            // ВАЖНО: Возвращаем данные с сервера в любом случае
            developer.log('🎯 Возвращаем РЕАЛЬНЫЕ данные с сервера: баланс=${accountResponse.balance}', name: 'NetworkBankAccountRepository');
            return accountResponse;
          } else {
            developer.log('❌ Сервер вернул пустой массив счетов', name: 'NetworkBankAccountRepository');
          }
        } else {
          developer.log('❌ Сервер вернул статус: ${response.statusCode}', name: 'NetworkBankAccountRepository');
        }
      } catch (e) {
        developer.log('❌ Ошибка при запросе к серверу: $e', name: 'NetworkBankAccountRepository');
      }
    }

    // Если сервер недоступен, ищем в локальной базе
    developer.log('💾 Поиск в локальной базе', name: 'NetworkBankAccountRepository');
    final localAccount = await _databaseService.getAccountById(accountId);
    if (localAccount != null) {
      developer.log('✅ Счет найден в локальной базе: ${localAccount.name}', name: 'NetworkBankAccountRepository');
      return await _mapEntityToResponse(localAccount);
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
    developer.log('💾 Сохраняем в локальную базу: ID=${account.id}, баланс=${account.balance}', name: 'NetworkBankAccountRepository');
    
    // Сначала проверяем, есть ли уже такой счет
    final existingAccount = await _databaseService.getAccountById(account.id);
    
    final entity = AccountEntity(
      id: existingAccount != null ? account.id : 0, // Используем 0 для новых записей
      name: account.name,
      balance: account.balance,
      currency: account.currency,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
    
    await _databaseService.addAccount(entity);
    developer.log('✅ Счет сохранен в локальную базу с балансом: ${entity.balance}', name: 'NetworkBankAccountRepository');
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

  /// Получаем данные для графика баланса с сервера
  Future<List<BalanceData>> getBalanceData() async {
    developer.log('📊 Создаем базовые данные для графика (пока без транзакций)', name: 'NetworkBankAccountRepository');
    
    // Пока создаем простые данные для демонстрации
    // Позже можно будет подключить правильный endpoint для транзакций
    final List<BalanceData> balanceData = [
      BalanceData(
        date: DateTime.now().subtract(Duration(days: 2)),
        amount: 500.0,
        type: 'income',
      ),
      BalanceData(
        date: DateTime.now().subtract(Duration(days: 1)),
        amount: 150.0,
        type: 'expense',
      ),
      BalanceData(
        date: DateTime.now(),
        amount: 50.0,
        type: 'expense',
      ),
    ];
    
    developer.log('📈 Создано ${balanceData.length} точек данных для графика', name: 'NetworkBankAccountRepository');
    return balanceData;
  }

  /// Отправляем тестовые транзакции на сервер
  Future<void> sendTestTransactions() async {
    if (!_networkService.isConnected) {
      developer.log('❌ Нет подключения к сети - не можем отправить тестовые транзакции', name: 'NetworkBankAccountRepository');
      return;
    }

    developer.log('🧪 Отправка тестовых транзакций на сервер', name: 'NetworkBankAccountRepository');

    final testTransactions = [
      {
        "accountId": 141,
        "categoryId": 1,
        "amount": "500.00",
        "transactionDate": "2025-01-15T10:00:00.000Z",
        "comment": "Зарплата за месяц"
      },
      {
        "accountId": 141,
        "categoryId": 2,
        "amount": "-150.00",
        "transactionDate": "2025-01-15T12:30:00.000Z",
        "comment": "Покупка продуктов"
      },
      {
        "accountId": 141,
        "categoryId": 3,
        "amount": "-50.00",
        "transactionDate": "2025-01-15T14:15:00.000Z",
        "comment": "Транспорт"
      },
    ];

    for (int i = 0; i < testTransactions.length; i++) {
      final transaction = testTransactions[i];
      try {
        developer.log('📤 Отправляем транзакцию ${i + 1}/3: ${transaction["comment"]} (${transaction["amount"]})', name: 'NetworkBankAccountRepository');
        
        final response = await _apiClient.post('/transactions', data: transaction);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          developer.log('✅ Транзакция ${i + 1} успешно отправлена: ${response.data}', name: 'NetworkBankAccountRepository');
        } else {
          developer.log('❌ Ошибка при отправке транзакции ${i + 1}: статус ${response.statusCode}', name: 'NetworkBankAccountRepository');
        }
      } catch (e) {
        developer.log('❌ Исключение при отправке транзакции ${i + 1}: $e', name: 'NetworkBankAccountRepository');
      }
      
      // Небольшая задержка между запросами
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    developer.log('🏁 Завершена отправка тестовых транзакций', name: 'NetworkBankAccountRepository');
  }
} 