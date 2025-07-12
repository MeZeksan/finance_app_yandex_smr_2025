import 'dart:convert';
import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/api_client.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/objectbox.g.dart';
import 'dart:developer' as developer;

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
    developer.log('📋 Backup operation added: ${operationType.name} ${dataType.name} $originalId', name: 'BackupService');
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
      developer.log('📵 No network connection. Skipping sync.', name: 'BackupService');
      return false;
    }

    final pendingOperations = await getPendingBackupOperations();
    if (pendingOperations.isEmpty) {
      developer.log('✅ No pending operations to sync.', name: 'BackupService');
      return true;
    }

    developer.log('🔄 Syncing ${pendingOperations.length} pending operations', name: 'BackupService');
    bool allSynced = true;
    
    for (final operation in pendingOperations) {
      try {
        developer.log('🔄 Syncing operation: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId}', name: 'BackupService');
        final success = await _syncOperation(operation);
        if (success) {
          await markOperationAsSynced(operation.id);
          developer.log('✅ Operation synced successfully: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId}', name: 'BackupService');
        } else {
          allSynced = false;
          await markOperationAsFailed(operation.id, 'Unknown sync error');
          developer.log('❌ Operation sync failed: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId}', name: 'BackupService');
        }
      } catch (e) {
        allSynced = false;
        await markOperationAsFailed(operation.id, e.toString());
        developer.log('❌ Error syncing operation: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId} - $e', name: 'BackupService');
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
      developer.log('❌ Error syncing operation: $e', name: 'BackupService');
      return false;
    }
  }

  /// Синхронизировать операцию с транзакцией
  Future<bool> _syncTransactionOperation(BackupOperationEntity operation, Map<String, dynamic> data) async {
    try {
      switch (operation.operationTypeEnum) {
        case BackupOperationType.create:
          developer.log('🔄 Creating transaction on server: ${json.encode(data)}', name: 'BackupService');
          final response = await _apiClient.post('/transactions', data: data);
          developer.log('📊 Server response: ${response.statusCode} - ${response.data}', name: 'BackupService');
          
          final isSuccess = response.statusCode == 200 || response.statusCode == 201;
          if (isSuccess) {
            developer.log('✅ Transaction created successfully on server', name: 'BackupService');
          } else {
            developer.log('❌ Failed to create transaction: ${response.statusCode}', name: 'BackupService');
          }
          return isSuccess;
        
        case BackupOperationType.update:
          developer.log('🔄 Updating transaction ${operation.originalId} on server: ${json.encode(data)}', name: 'BackupService');
          final response = await _apiClient.put('/transactions/${operation.originalId}', data: data);
          developer.log('📊 Server response: ${response.statusCode} - ${response.data}', name: 'BackupService');
          return response.statusCode == 200;
        
        case BackupOperationType.delete:
          developer.log('🔄 Deleting transaction ${operation.originalId} on server', name: 'BackupService');
          final response = await _apiClient.delete('/transactions/${operation.originalId}');
          developer.log('📊 Server response: ${response.statusCode} - ${response.data}', name: 'BackupService');
          return response.statusCode == 200 || response.statusCode == 204;
      }
    } catch (e) {
      developer.log('❌ Error syncing transaction: $e', name: 'BackupService');
      throw e;
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
      developer.log('🧹 Cleaned up ${oldOperations.length} old failed operations', name: 'BackupService');
    }
  }

  /// Принудительно очистить все ожидающие операции (для отладки)
  Future<void> clearAllPendingOperations() async {
    developer.log('🧹 Принудительная очистка всех ожидающих операций', name: 'BackupService');
    
    final pendingOperations = await getPendingBackupOperations();
    developer.log('📊 Найдено ${pendingOperations.length} ожидающих операций', name: 'BackupService');
    
    for (final operation in pendingOperations) {
      await _deleteBackupOperation(operation.id);
      developer.log('🗑️ Удалена операция: ${operation.operationTypeEnum.name} ${operation.dataTypeEnum.name} ${operation.originalId}', name: 'BackupService');
    }
    
    developer.log('✅ Все ожидающие операции очищены', name: 'BackupService');
  }
} 