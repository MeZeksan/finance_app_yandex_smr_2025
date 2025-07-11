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
import 'dart:developer' as developer;

class NetworkTransactionRepository implements TransactionRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final ApiClient _apiClient = ApiClient();
  final NetworkService _networkService = NetworkService();
  final BackupService _backupService = BackupService();

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
    developer.log(
      '🔍 Получение транзакций за период: ${dateFrom.toLocal()} - ${dateTo.toLocal()}, isIncome: $isIncome',
      name: 'NetworkTransactionRepository',
    );

    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация ожидающих операций', name: 'NetworkTransactionRepository');
      await _backupService.syncPendingOperations();
    }

    // Получаем из локальной базы с фильтрацией
    developer.log('💾 Поиск в локальной базе', name: 'NetworkTransactionRepository');
    final localTransactions = await _databaseService.getTransactionsByDateRange(
      startDate: dateFrom,
      endDate: dateTo,
      isIncome: isIncome,
    );

    developer.log('📊 Найдено ${localTransactions.length} транзакций', name: 'NetworkTransactionRepository');

    return await Future.wait(localTransactions.map(_mapEntityToResponse));
  }

  @override
  Future<TransactionResponce> addTransaction(TransactionRequest request) async {
    developer.log(
      '➕ Добавление новой транзакции: ${request.amount} ${request.transactionDate}',
      name: 'NetworkTransactionRepository',
    );

    // Создаем временный ID для локального хранения
    final tempId = DateTime.now().millisecondsSinceEpoch;
    
    // Сначала сохраняем локально
    developer.log('💾 Сохранение транзакции локально', name: 'NetworkTransactionRepository');
    final entity = _mapRequestToEntity(request, tempId);
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
      await _backupService.syncPendingOperations();
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
      await _backupService.syncPendingOperations();
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
        await _backupService.syncPendingOperations();
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
    // Получаем связанные сущности
    final accountEntity = await _databaseService.getAccountById(entity.accountId);
    final categoryEntity = await _databaseService.getCategoryById(entity.categoryId);
    
    if (accountEntity == null || categoryEntity == null) {
      throw Exception('Account or Category not found for transaction ${entity.id}');
    }

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
    
    // Устанавливаем связи
    entity.accountId = request.accountId;
    entity.categoryId = request.categoryId;
    
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
    
    // Устанавливаем связи
    entity.accountId = transaction.account.id;
    entity.categoryId = transaction.category.id;
    
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
} 