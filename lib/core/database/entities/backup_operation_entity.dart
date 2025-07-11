import 'package:objectbox/objectbox.dart';

enum BackupOperationType {
  create,
  update,
  delete,
}

enum BackupDataType {
  transaction,
  account,
  category,
}

@Entity()
class BackupOperationEntity {
  @Id()
  int id = 0;

  /// Тип операции (создание, изменение, удаление)
  int operationType = BackupOperationType.create.index;

  /// Тип данных (транзакция, аккаунт, категория)
  int dataType = BackupDataType.transaction.index;

  /// ID оригинальной записи
  int originalId = 0;

  /// JSON данные операции
  String jsonData = '';

  /// Временная метка создания операции
  @Property(type: PropertyType.date)
  DateTime createdAt = DateTime.now();

  /// Флаг попытки синхронизации
  bool attemptedSync = false;

  /// Количество попыток синхронизации
  int syncAttempts = 0;

  /// Временная метка последней попытки синхронизации
  @Property(type: PropertyType.date)
  DateTime? lastSyncAttempt;

  /// Сообщение об ошибке последней попытки синхронизации
  String? lastSyncError;

  BackupOperationEntity({
    this.id = 0,
    required this.operationType,
    required this.dataType,
    required this.originalId,
    required this.jsonData,
    DateTime? createdAt,
    this.attemptedSync = false,
    this.syncAttempts = 0,
    this.lastSyncAttempt,
    this.lastSyncError,
  }) : createdAt = createdAt ?? DateTime.now();

  // Методы для удобной работы с enum
  BackupOperationType get operationTypeEnum => 
      BackupOperationType.values[operationType];
  
  set operationTypeEnum(BackupOperationType type) => 
      operationType = type.index;

  BackupDataType get dataTypeEnum => 
      BackupDataType.values[dataType];
  
  set dataTypeEnum(BackupDataType type) => 
      dataType = type.index;

  void markSyncAttempt({String? error}) {
    syncAttempts++;
    lastSyncAttempt = DateTime.now();
    if (error != null) {
      lastSyncError = error;
      attemptedSync = false;
    } else {
      attemptedSync = true;
      lastSyncError = null;
    }
  }
} 