import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/api_client.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/core/services/backup_service.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_request/transaction_request.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/transaction_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/account_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/repositoryI/network_category_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/repositoryI/network_bank_account_repository.dart';
import 'dart:developer' as developer;

class NetworkTransactionRepository implements TransactionRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final ApiClient _apiClient = ApiClient();
  final NetworkService _networkService = NetworkService();
  final BackupService _backupService = BackupService();
  final NetworkBankAccountRepository _accountRepository = NetworkBankAccountRepository();
  
  static bool _initialized = false;
  
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    developer.log('🔧 Инициализация NetworkTransactionRepository', name: 'NetworkTransactionRepository');
    // При первом запуске очищаем старые проблемные операции
    await _backupService.clearAllPendingOperations();
    _initialized = true;
  }

  @override
  Future<TransactionResponce?> getTransactionById(int transactionId) async {
    developer.log(
      '🔍 Получение транзакции по ID: $transactionId',
      name: 'NetworkTransactionRepository',
    );

    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация ожидающих операций', name: 'NetworkTransactionRepository');
      await _backupService.syncPendingOperations();
    }

    // Ищем в локальной базе
    developer.log('💾 Поиск в локальной базе', name: 'NetworkTransactionRepository');
    final localTransaction = await _databaseService.getTransactionById(transactionId);
    if (localTransaction != null) {
      developer.log('✅ Транзакция найдена в локальной базе', name: 'NetworkTransactionRepository');
      return await _mapEntityToResponse(localTransaction);
    }

    // Если нет в локальной базе и есть сеть, запрашиваем с сервера
    if (_networkService.isConnected) {
      developer.log('🌐 Запрос транзакции с сервера', name: 'NetworkTransactionRepository');
      try {
        final response = await _apiClient.get('/transactions/$transactionId');
        if (response.statusCode == 200 && response.data != null) {
          final transactionData = response.data as Map<String, dynamic>;
          final transactionResponse = TransactionResponce.fromJson(transactionData);
          
          developer.log('✅ Транзакция получена с сервера, сохраняем локально', name: 'NetworkTransactionRepository');
          // Сохраняем в локальную базу
          await _saveTransactionToLocal(transactionResponse);
          return transactionResponse;
        }
      } catch (e) {
        developer.log('❌ Ошибка при получении транзакции с сервера: $e', name: 'NetworkTransactionRepository');
      }
    } else {
      developer.log('📵 Нет подключения к сети', name: 'NetworkTransactionRepository');
    }

    developer.log('❌ Транзакция не найдена', name: 'NetworkTransactionRepository');
    return null;
  }



  @override
  Future<List<TransactionResponce>> getTransactionsByDateAndType({
    required DateTime dateFrom,
    required DateTime dateTo,
    required bool isIncome,
  }) async {
    await _ensureInitialized();
    
    developer.log(
      '🔍 Получение транзакций за период: ${dateFrom.toLocal()} - ${dateTo.toLocal()}, isIncome: $isIncome',
      name: 'NetworkTransactionRepository',
    );

    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация ожидающих операций', name: 'NetworkTransactionRepository');
      await _backupService.syncPendingOperations();

      // КРИТИЧНО: Сначала загружаем все категории через CategoryRepository
      developer.log('📋 Предварительная загрузка категорий через CategoryRepository', name: 'NetworkTransactionRepository');
      try {
        // Импортируем и используем CategoryRepository для загрузки категорий
        final categoryRepository = NetworkCategoryRepository();
        final categories = await categoryRepository.getAllCategories();
        developer.log('📊 Предзагружено ${categories.length} категорий', name: 'NetworkTransactionRepository');
      } catch (e) {
        developer.log('⚠️ Ошибка предзагрузки категорий через репозиторий: $e', name: 'NetworkTransactionRepository');
      }

      // Используем локальную базу данных для отображения транзакций
      developer.log('💾 Используем локальную базу для получения транзакций', name: 'NetworkTransactionRepository');
    } else {
      developer.log('📵 Нет подключения к сети', name: 'NetworkTransactionRepository');
    }

    // Если сервер недоступен, получаем из локальной базы с фильтрацией
    developer.log('💾 Поиск в локальной базе', name: 'NetworkTransactionRepository');
    final localTransactions = await _databaseService.getTransactionsByDateRange(
      startDate: dateFrom,
      endDate: dateTo,
      isIncome: isIncome,
    );

    developer.log('📊 Найдено ${localTransactions.length} транзакций в локальной базе', name: 'NetworkTransactionRepository');
    return await Future.wait(localTransactions.map(_mapEntityToResponse));
  }

  @override
  Future<TransactionResponce> addTransaction(TransactionRequest request) async {
    await _ensureInitialized();
    
    developer.log(
      '➕ Добавление новой транзакции: ${request.amount} ${request.transactionDate}',
      name: 'NetworkTransactionRepository',
    );
    
    // Сначала сохраняем локально с ID = 0 для автогенерации
    developer.log('💾 Сохранение транзакции локально', name: 'NetworkTransactionRepository');
    final entity = _mapRequestToEntity(request, 0); // Используем 0 для автогенерации ID
    final localId = await _databaseService.addTransaction(entity);
    
    // Добавляем в бэкап для синхронизации
    developer.log('📋 Добавление в очередь синхронизации', name: 'NetworkTransactionRepository');
    await _backupService.addBackupOperation(
      operationType: BackupOperationType.create,
      dataType: BackupDataType.transaction,
      originalId: localId,
      data: request.toJson(),
    );

    // Если есть сеть, пытаемся сразу синхронизировать
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация с сервером', name: 'NetworkTransactionRepository');
      final syncSuccess = await _backupService.syncPendingOperations();
      
      // Если синхронизация прошла успешно, обновляем баланс
      if (syncSuccess) {
        developer.log('💰 Обновляем баланс после успешного создания транзакции', name: 'NetworkTransactionRepository');
        try {
          await _accountRepository.refreshBalance(request.accountId);
          developer.log('✅ Баланс успешно обновлен', name: 'NetworkTransactionRepository');
        } catch (e) {
          developer.log('⚠️ Ошибка при обновлении баланса: $e', name: 'NetworkTransactionRepository');
        }
      }
    } else {
      developer.log('📵 Нет подключения к сети, синхронизация отложена', name: 'NetworkTransactionRepository');
    }

    // Возвращаем ответ на основе локальных данных
    final savedEntity = await _databaseService.getTransactionById(localId);
    developer.log('✅ Транзакция добавлена с ID: $localId', name: 'NetworkTransactionRepository');
    return await _mapEntityToResponse(savedEntity!);
  }

  @override
  Future<TransactionResponce> updateTransaction(
    int transactionId,
    TransactionRequest request,
  ) async {
    developer.log(
      '✏️ Обновление транзакции ID: $transactionId',
      name: 'NetworkTransactionRepository',
    );

    // Обновляем локально
    developer.log('💾 Обновление транзакции локально', name: 'NetworkTransactionRepository');
    final entity = _mapRequestToEntity(request, transactionId);
    await _databaseService.addTransaction(entity);

    // Добавляем в бэкап для синхронизации
    developer.log('📋 Добавление в очередь синхронизации', name: 'NetworkTransactionRepository');
    await _backupService.addBackupOperation(
      operationType: BackupOperationType.update,
      dataType: BackupDataType.transaction,
      originalId: transactionId,
      data: request.toJson(),
    );

    // Если есть сеть, пытаемся сразу синхронизировать
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация с сервером', name: 'NetworkTransactionRepository');
      final syncSuccess = await _backupService.syncPendingOperations();
      
      // Если синхронизация прошла успешно, обновляем баланс
      if (syncSuccess) {
        developer.log('💰 Обновляем баланс после обновления транзакции', name: 'NetworkTransactionRepository');
        try {
          await _accountRepository.refreshBalance(request.accountId);
          developer.log('✅ Баланс успешно обновлен', name: 'NetworkTransactionRepository');
        } catch (e) {
          developer.log('⚠️ Ошибка при обновлении баланса: $e', name: 'NetworkTransactionRepository');
        }
      }
    } else {
      developer.log('📵 Нет подключения к сети, синхронизация отложена', name: 'NetworkTransactionRepository');
    }

    // Возвращаем обновленные данные
    final updatedEntity = await _databaseService.getTransactionById(transactionId);
    developer.log('✅ Транзакция обновлена', name: 'NetworkTransactionRepository');
    return await _mapEntityToResponse(updatedEntity!);
  }

  @override
  Future<bool> deleteTransaction(int transactionId) async {
    developer.log(
      '🗑️ Удаление транзакции ID: $transactionId',
      name: 'NetworkTransactionRepository',
    );

    // Удаляем локально
    developer.log('💾 Удаление транзакции локально', name: 'NetworkTransactionRepository');
    final deleted = await _databaseService.deleteTransaction(transactionId);
    
    if (deleted) {
      developer.log('📋 Добавление в очередь синхронизации', name: 'NetworkTransactionRepository');
      // Добавляем в бэкап для синхронизации
      await _backupService.addBackupOperation(
        operationType: BackupOperationType.delete,
        dataType: BackupDataType.transaction,
        originalId: transactionId,
        data: {'id': transactionId},
      );

      // Если есть сеть, пытаемся сразу синхронизировать
      if (_networkService.isConnected) {
        developer.log('📡 Синхронизация с сервером', name: 'NetworkTransactionRepository');
        final syncSuccess = await _backupService.syncPendingOperations();
        
        // Если синхронизация прошла успешно, обновляем баланс
        if (syncSuccess) {
          developer.log('💰 Обновляем баланс после удаления транзакции', name: 'NetworkTransactionRepository');
          try {
            // Получаем информацию об удаленной транзакции для обновления правильного счета
            // Поскольку транзакция уже удалена, используем все счета
            final accounts = await _databaseService.getAllAccounts();
            if (accounts.isNotEmpty) {
              await _accountRepository.refreshBalance(accounts.first.id);
              developer.log('✅ Баланс успешно обновлен', name: 'NetworkTransactionRepository');
            }
          } catch (e) {
            developer.log('⚠️ Ошибка при обновлении баланса: $e', name: 'NetworkTransactionRepository');
          }
        }
      } else {
        developer.log('📵 Нет подключения к сети, синхронизация отложена', name: 'NetworkTransactionRepository');
      }
      
      developer.log('✅ Транзакция удалена', name: 'NetworkTransactionRepository');
    } else {
      developer.log('❌ Ошибка при удалении транзакции', name: 'NetworkTransactionRepository');
    }
    
    return deleted;
  }

  // Вспомогательные методы для маппинга данных
  Future<TransactionResponce> _mapEntityToResponse(TransactionEntity entity) async {
    developer.log('🔄 Маппинг транзакции ID: ${entity.id}, accountId: ${entity.accountId}, categoryId: ${entity.categoryId}', name: 'NetworkTransactionRepository');
    
    // Получаем связанные сущности - сначала по ID, потом по другим критериям
    AccountEntity? accountEntity = await _databaseService.getAccountById(entity.accountId);
    
    // Если не найден по ID, ищем первый доступный счет
    if (accountEntity == null) {
      final allAccounts = await _databaseService.getAllAccounts();
      if (allAccounts.isNotEmpty) {
        accountEntity = allAccounts.first;
        developer.log('⚠️ Счет ${entity.accountId} не найден по ID, используем первый доступный: ${accountEntity.name}', name: 'NetworkTransactionRepository');
      }
    }
    
    CategoryEntity? categoryEntity = await _databaseService.getCategoryById(entity.categoryId);
    
    // Если не найдена по ID, ищем среди всех категорий
    if (categoryEntity == null) {
      final allCategories = await _databaseService.getAllCategories();
      // Определяем тип транзакции по сумме
      final amount = double.tryParse(entity.amount) ?? 0.0;
      final isIncome = amount > 0;
      
      // Ищем подходящую категорию по типу
      for (final cat in allCategories) {
        if (cat.isIncome == isIncome) {
          categoryEntity = cat;
          developer.log('⚠️ Категория ${entity.categoryId} не найдена по ID, используем подходящую: ${cat.name}', name: 'NetworkTransactionRepository');
          break;
        }
      }
    }
    
    // Если счет не найден, создаем базовый
    if (accountEntity == null) {
      developer.log('⚠️ Счет ${entity.accountId} не найден, создаем базовый для транзакции ${entity.id}', name: 'NetworkTransactionRepository');
      accountEntity = AccountEntity(
        id: 0, // Используем 0 для автогенерации ID в ObjectBox
        name: 'Счет ${entity.accountId}',
        balance: '0.00',
        currency: 'RUB',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final newAccountId = await _databaseService.addAccount(accountEntity);
      accountEntity = await _databaseService.getAccountById(newAccountId);
      if (accountEntity == null) {
        throw Exception('Failed to create account for transaction ${entity.id}');
      }
    }

    // Если категория не найдена, создаем базовую
    if (categoryEntity == null) {
      developer.log('⚠️ Категория ${entity.categoryId} не найдена, создаем базовую для транзакции ${entity.id}', name: 'NetworkTransactionRepository');
      
      // Определяем тип категории по сумме (положительная = доход)
      final amount = double.tryParse(entity.amount) ?? 0.0;
      final isIncome = amount > 0;
      
      categoryEntity = CategoryEntity(
        id: 0, // Используем 0 для автогенерации ID в ObjectBox
        name: isIncome ? 'Доход' : 'Расход',
        emoji: isIncome ? '💰' : '💸',
        isIncome: isIncome,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final newCategoryId = await _databaseService.addCategory(categoryEntity);
      categoryEntity = await _databaseService.getCategoryById(newCategoryId);
      if (categoryEntity == null) {
        throw Exception('Failed to create category for transaction ${entity.id}');
      }
    }

    developer.log('✅ Маппинг завершен для транзакции ${entity.id}', name: 'NetworkTransactionRepository');
    return TransactionResponce(
      id: entity.id,
      account: _mapAccountEntityToBrief(accountEntity),
      category: _mapCategoryEntityToModel(categoryEntity),
      amount: entity.amount,
      transactionDate: entity.transactionDate,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TransactionEntity _mapRequestToEntity(TransactionRequest request, int id) {
    final now = DateTime.now();
    
    final entity = TransactionEntity(
      id: id,
      amount: request.amount,
      transactionDate: request.transactionDate,
      comment: request.comment,
      createdAt: now,
      updatedAt: now,
    );
    
    // Устанавливаем ID для связей - это будет использоваться в DatabaseService
    entity.accountId = request.accountId;
    entity.categoryId = request.categoryId;
    
    developer.log('🔗 Создана TransactionEntity: ID=$id, accountId=${request.accountId}, categoryId=${request.categoryId}', name: 'NetworkTransactionRepository');
    
    return entity;
  }

  Future<void> _saveTransactionToLocal(TransactionResponce transaction) async {
    final entity = TransactionEntity(
      id: transaction.id,
      amount: transaction.amount,
      transactionDate: transaction.transactionDate,
      comment: transaction.comment,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
    
    // Устанавливаем ID для связей
    entity.accountId = transaction.account.id;
    entity.categoryId = transaction.category.id;
    
    developer.log('💾 Сохранение локально: TransactionID=${transaction.id}, accountId=${transaction.account.id}, categoryId=${transaction.category.id}', name: 'NetworkTransactionRepository');
    
    await _databaseService.addTransaction(entity);
  }



  AccountBrief _mapAccountEntityToBrief(AccountEntity accountEntity) {
    return AccountBrief(
      id: accountEntity.id,
      name: accountEntity.name,
      balance: accountEntity.balance,
      currency: accountEntity.currency,
    );
  }

  Category _mapCategoryEntityToModel(CategoryEntity categoryEntity) {
    return Category(
      id: categoryEntity.id,
      name: categoryEntity.name,
      emoji: categoryEntity.emoji,
      isIncome: categoryEntity.isIncome,
    );
  }

  /// Парсим транзакцию с сервера в TransactionResponce
  Future<TransactionResponce?> _parseServerTransactionToResponse(Map<String, dynamic> transactionJson) async {
    try {
      final transactionId = transactionJson['id'];
      final accountId = transactionJson['accountId'];
      final categoryId = transactionJson['categoryId'];
      final amount = transactionJson['amount']?.toString() ?? '0.00';
      final transactionDate = DateTime.parse(transactionJson['transactionDate'] ?? DateTime.now().toIso8601String());
      final comment = transactionJson['comment']?.toString();
      final createdAt = DateTime.parse(transactionJson['createdAt'] ?? DateTime.now().toIso8601String());
      final updatedAt = DateTime.parse(transactionJson['updatedAt'] ?? DateTime.now().toIso8601String());

      // Получаем связанные сущности
      AccountEntity? accountEntity = await _databaseService.getAccountById(accountId);
      
      // Сначала пытаемся найти категорию по ID
      CategoryEntity? categoryEntity = await _databaseService.getCategoryById(categoryId);
      
      // Если не найдена по ID, ищем среди всех категорий по серверному ID через комментарий или другим способом
      if (categoryEntity == null) {
        developer.log('⚠️ Категория с ID $categoryId не найдена, ищем среди всех категорий', name: 'NetworkTransactionRepository');
        final allCategories = await _databaseService.getAllCategories();
        
        // Определяем тип категории по сумме (положительная = доход)
        final isIncome = double.tryParse(amount) != null && double.parse(amount) > 0;
        
        // Ищем подходящую категорию по типу (доход/расход)
        for (final cat in allCategories) {
          if (cat.isIncome == isIncome) {
            categoryEntity = cat;
            developer.log('✅ Найдена подходящая категория: ${cat.name} (ID: ${cat.id})', name: 'NetworkTransactionRepository');
            break;
          }
        }
      }

      // Если счет не найден, создаем базовый
      if (accountEntity == null) {
        developer.log('⚠️ Счет $accountId не найден, создаем базовый', name: 'NetworkTransactionRepository');
        accountEntity = AccountEntity(
          id: 0, // Используем 0 для автогенерации ID в ObjectBox
          name: 'Счет $accountId',
          balance: '0.00',
          currency: 'RUB',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final newAccountId = await _databaseService.addAccount(accountEntity);
        accountEntity = await _databaseService.getAccountById(newAccountId);
        if (accountEntity == null) {
          throw Exception('Failed to create account');
        }
      }

      // Если категория все еще не найдена, создаем базовую
      if (categoryEntity == null) {
        developer.log('⚠️ Категория все еще не найдена, создаем базовую', name: 'NetworkTransactionRepository');
        // Определяем тип категории по сумме (положительная = доход)
        final isIncome = double.tryParse(amount) != null && double.parse(amount) > 0;
        categoryEntity = CategoryEntity(
          id: 0, // Используем 0 для автогенерации ID в ObjectBox
          name: isIncome ? 'Доход' : 'Расход',
          emoji: isIncome ? '💰' : '💸',
          isIncome: isIncome,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final newCategoryId = await _databaseService.addCategory(categoryEntity);
        categoryEntity = await _databaseService.getCategoryById(newCategoryId);
        if (categoryEntity == null) {
          throw Exception('Failed to create category');
        }
      }

      return TransactionResponce(
        id: transactionId,
        account: _mapAccountEntityToBrief(accountEntity),
        category: _mapCategoryEntityToModel(categoryEntity),
        amount: amount,
        transactionDate: transactionDate,
        comment: comment,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      developer.log('❌ Ошибка парсинга транзакции: $e', name: 'NetworkTransactionRepository');
      return null;
    }
  }
} 