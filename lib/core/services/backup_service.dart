import 'dart:convert';
import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/api_client.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/objectbox.g.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _databaseService = DatabaseService.instance;
  final ApiClient _apiClient = ApiClient();
  final NetworkService _networkService = NetworkService();

  /// Добавить операцию в бэкап для синхронизации
  Future<void> addBackupOperation({
    required BackupOperationType operationType,
    required BackupDataType dataType,
    required int originalId,
    required Map<String, dynamic> data,
  }) async {
    final jsonData = json.encode(data);
    
    // Проверяем, существует ли уже операция для этой записи
    final existingOperations = await _getBackupOperationsForRecord(dataType, originalId);
    
    // Если есть операция создания, а сейчас удаление - удаляем обе
    if (operationType == BackupOperationType.delete) {
      for (final existing in existingOperations) {
        if (existing.operationTypeEnum == BackupOperationType.create) {
          await _deleteBackupOperation(existing.id);
          return; // Не создаем операцию удаления для записи, которая не была создана на сервере
        }
      }
    }
    
    // Если есть несколько операций обновления, заменяем их одной
    if (operationType == BackupOperationType.update) {
      final updateOperations = existingOperations
          .where((op) => op.operationTypeEnum == BackupOperationType.update)
          .toList();
      
      for (final updateOp in updateOperations) {
        await _deleteBackupOperation(updateOp.id);
      }
    }
    
    final backupOperation = BackupOperationEntity(
      operationType: operationType.index,
      dataType: dataType.index,
      originalId: originalId,
      jsonData: jsonData,
    );
    
    await _databaseService.objectBox.backupOperationBox.putAsync(backupOperation);
    print('Backup operation added: ${operationType.name} ${dataType.name} $originalId');
  }

  /// Получить все операции для синхронизации
  Future<List<BackupOperationEntity>> getPendingBackupOperations() async {
    final query = _databaseService.objectBox.backupOperationBox
        .query(BackupOperationEntity_.attemptedSync.equals(false))
        .order(BackupOperationEntity_.createdAt)
        .build();
    
    final operations = query.find();
    query.close();
    return operations;
  }

  /// Получить операции для конкретной записи
  Future<List<BackupOperationEntity>> _getBackupOperationsForRecord(
      BackupDataType dataType, int originalId) async {
    final query = _databaseService.objectBox.backupOperationBox
        .query(BackupOperationEntity_.dataType.equals(dataType.index) &
               BackupOperationEntity_.originalId.equals(originalId))
        .build();
    
    final operations = query.find();
    query.close();
    return operations;
  }

  /// Удалить операцию из бэкапа
  Future<void> _deleteBackupOperation(int id) async {
    await _databaseService.objectBox.backupOperationBox.removeAsync(id);
  }

  /// Пометить операцию как синхронизированную
  Future<void> markOperationAsSynced(int operationId) async {
    final operation = _databaseService.objectBox.backupOperationBox.get(operationId);
    if (operation != null) {
      operation.markSyncAttempt();
      await _databaseService.objectBox.backupOperationBox.putAsync(operation);
      await _deleteBackupOperation(operationId);
    }
  }

  /// Пометить операцию как неудачную попытку синхронизации
  Future<void> markOperationAsFailed(int operationId, String error) async {
    final operation = _databaseService.objectBox.backupOperationBox.get(operationId);
    if (operation != null) {
      operation.markSyncAttempt(error: error);
      await _databaseService.objectBox.backupOperationBox.putAsync(operation);
    }
  }

  /// Синхронизировать все ожидающие операции
  Future<bool> syncPendingOperations() async {
    if (!_networkService.isConnected) {
      print('No network connection. Skipping sync.');
      return false;
    }

    final pendingOperations = await getPendingBackupOperations();
    if (pendingOperations.isEmpty) {
      print('No pending operations to sync.');
      return true;
    }

    bool allSynced = true;
    
    for (final operation in pendingOperations) {
      try {
        final success = await _syncOperation(operation);
        if (success) {
          await markOperationAsSynced(operation.id);
          print('Operation synced successfully: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId}');
        } else {
          allSynced = false;
          await markOperationAsFailed(operation.id, 'Unknown sync error');
        }
      } catch (e) {
        allSynced = false;
        await markOperationAsFailed(operation.id, e.toString());
        print('Failed to sync operation: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId} - $e');
      }
    }

    return allSynced;
  }

  /// Синхронизировать конкретную операцию
  Future<bool> _syncOperation(BackupOperationEntity operation) async {
    final data = json.decode(operation.jsonData) as Map<String, dynamic>;
    
    try {
      switch (operation.dataTypeEnum) {
        case BackupDataType.transaction:
          return await _syncTransactionOperation(operation, data);
        case BackupDataType.account:
          return await _syncAccountOperation(operation, data);
        case BackupDataType.category:
          return await _syncCategoryOperation(operation, data);
      }
    } catch (e) {
      print('Error syncing operation: $e');
      return false;
    }
  }

  /// Синхронизировать операцию с транзакцией
  Future<bool> _syncTransactionOperation(BackupOperationEntity operation, Map<String, dynamic> data) async {
    switch (operation.operationTypeEnum) {
      case BackupOperationType.create:
        final response = await _apiClient.post('/transactions', data: data);
        return response.statusCode == 200 || response.statusCode == 201;
      
      case BackupOperationType.update:
        final response = await _apiClient.put('/transactions/${operation.originalId}', data: data);
        return response.statusCode == 200;
      
      case BackupOperationType.delete:
        final response = await _apiClient.delete('/transactions/${operation.originalId}');
        return response.statusCode == 200 || response.statusCode == 204;
    }
  }

  /// Синхронизировать операцию с аккаунтом
  Future<bool> _syncAccountOperation(BackupOperationEntity operation, Map<String, dynamic> data) async {
    switch (operation.operationTypeEnum) {
      case BackupOperationType.create:
        final response = await _apiClient.post('/accounts', data: data);
        return response.statusCode == 200 || response.statusCode == 201;
      
      case BackupOperationType.update:
        final response = await _apiClient.put('/accounts/${operation.originalId}', data: data);
        return response.statusCode == 200;
      
      case BackupOperationType.delete:
        final response = await _apiClient.delete('/accounts/${operation.originalId}');
        return response.statusCode == 200 || response.statusCode == 204;
    }
  }

  /// Синхронизировать операцию с категорией
  Future<bool> _syncCategoryOperation(BackupOperationEntity operation, Map<String, dynamic> data) async {
    switch (operation.operationTypeEnum) {
      case BackupOperationType.create:
        final response = await _apiClient.post('/categories', data: data);
        return response.statusCode == 200 || response.statusCode == 201;
      
      case BackupOperationType.update:
        final response = await _apiClient.put('/categories/${operation.originalId}', data: data);
        return response.statusCode == 200;
      
      case BackupOperationType.delete:
        final response = await _apiClient.delete('/categories/${operation.originalId}');
        return response.statusCode == 200 || response.statusCode == 204;
    }
  }

  /// Очистить старые неуспешные операции (старше 7 дней)
  Future<void> cleanupOldOperations() async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final query = _databaseService.objectBox.backupOperationBox
        .query(BackupOperationEntity_.createdAt.lessThan(weekAgo.millisecondsSinceEpoch) &
               BackupOperationEntity_.syncAttempts.greaterThan(3))
        .build();
    
    final oldOperations = query.find();
    query.close();
    
    for (final operation in oldOperations) {
      await _deleteBackupOperation(operation.id);
    }
    
    if (oldOperations.isNotEmpty) {
      print('Cleaned up ${oldOperations.length} old failed operations');
    }
  }
} 