import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/api_client.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/core/services/backup_service.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/category_entity.dart' as db;

class NetworkCategoryRepository implements CategoryRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final ApiClient _apiClient = ApiClient();
  final NetworkService _networkService = NetworkService();
  final BackupService _backupService = BackupService();

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
      
      // Пытаемся загрузить с сервера
      try {
        final response = await _apiClient.get('/categories');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final categories = (data['data'] as List)
              .map((json) => Category.fromJson(json))
              .toList();
          
          // Обновляем локальную базу
          await _updateLocalCategories(categories);
          return categories.map((cat) => cat.toEntity()).toList();
        }
      } catch (e) {
        print('Error fetching categories from server: $e');
      }
    }

    // Возвращаем данные из локальной базы
    final localCategories = await _databaseService.getAllCategories();
    return localCategories.map(_mapDbEntityToDomainEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
      
      // Пытаемся загрузить с сервера
      try {
        final response = await _apiClient.get('/categories?type=income');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final categories = (data['data'] as List)
              .map((json) => Category.fromJson(json))
              .where((cat) => cat.isIncome)
              .toList();
          
          // Обновляем локальную базу
          await _updateLocalCategories(categories);
          return categories.map((cat) => cat.toEntity()).toList();
        }
      } catch (e) {
        print('Error fetching income categories from server: $e');
      }
    }

    // Возвращаем данные из локальной базы
    final localCategories = await _databaseService.getCategoriesByType(true);
    return localCategories.map(_mapDbEntityToDomainEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
      
      // Пытаемся загрузить с сервера
      try {
        final response = await _apiClient.get('/categories?type=expense');
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final categories = (data['data'] as List)
              .map((json) => Category.fromJson(json))
              .where((cat) => !cat.isIncome)
              .toList();
          
          // Обновляем локальную базу
          await _updateLocalCategories(categories);
          return categories.map((cat) => cat.toEntity()).toList();
        }
      } catch (e) {
        print('Error fetching expense categories from server: $e');
      }
    }

    // Возвращаем данные из локальной базы
    final localCategories = await _databaseService.getCategoriesByType(false);
    return localCategories.map(_mapDbEntityToDomainEntity).toList();
  }

  // Дополнительные методы для CRUD операций
  Future<CategoryEntity> createCategory(String name, String emoji, bool isIncome) async {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    
    // Создаем временную категорию локально
    final now = DateTime.now();
    final localCategory = db.CategoryEntity(
      id: tempId,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
      createdAt: now,
      updatedAt: now,
    );
    
    final localId = await _databaseService.addCategory(localCategory);
    
    // Добавляем в бэкап для синхронизации
    await _backupService.addBackupOperation(
      operationType: BackupOperationType.create,
      dataType: BackupDataType.category,
      originalId: localId,
      data: {
        'name': name,
        'emoji': emoji,
        'isIncome': isIncome,
      },
    );

    // Если есть сеть, пытаемся сразу синхронизировать
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
    }

    return CategoryEntity(
      id: localId,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
    );
  }

  Future<CategoryEntity> updateCategory(int id, String name, String emoji, bool isIncome) async {
    final now = DateTime.now();
    
    // Находим существующую категорию для получения createdAt
    final existingCategory = await _databaseService.getCategoryById(id);
    if (existingCategory == null) {
      throw Exception('Category not found');
    }
    
    final updatedCategory = db.CategoryEntity(
      id: id,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
      createdAt: existingCategory.createdAt,
      updatedAt: now,
    );
    
    await _databaseService.addCategory(updatedCategory);
    
    // Добавляем в бэкап для синхронизации
    await _backupService.addBackupOperation(
      operationType: BackupOperationType.update,
      dataType: BackupDataType.category,
      originalId: id,
      data: {
        'name': name,
        'emoji': emoji,
        'isIncome': isIncome,
      },
    );

    // Если есть сеть, пытаемся сразу синхронизировать
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
    }

    return CategoryEntity(
      id: id,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
    );
  }

  Future<bool> deleteCategory(int id) async {
    // Удаляем локально
    final deleted = await _databaseService.deleteCategory(id);
    
    if (deleted) {
      // Добавляем в бэкап для синхронизации
      await _backupService.addBackupOperation(
        operationType: BackupOperationType.delete,
        dataType: BackupDataType.category,
        originalId: id,
        data: {'id': id},
      );

      // Если есть сеть, пытаемся сразу синхронизировать
      if (_networkService.isConnected) {
        await _backupService.syncPendingOperations();
      }
    }
    
    return deleted;
  }

  Future<CategoryEntity?> getCategoryById(int id) async {
    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      await _backupService.syncPendingOperations();
    }

    // Ищем в локальной базе
    final localCategory = await _databaseService.getCategoryById(id);
    if (localCategory != null) {
      return _mapDbEntityToDomainEntity(localCategory);
    }

    // Если нет в локальной базе и есть сеть, запрашиваем с сервера
    if (_networkService.isConnected) {
      try {
        final response = await _apiClient.get('/categories/$id');
        if (response.statusCode == 200 && response.data != null) {
          final categoryData = response.data as Map<String, dynamic>;
          final category = Category.fromJson(categoryData);
          
          // Сохраняем в локальную базу
          await _saveCategoryToLocal(category);
          return category.toEntity();
        }
      } catch (e) {
        print('Error fetching category from server: $e');
      }
    }

    return null;
  }

  // Вспомогательные методы для маппинга данных
  CategoryEntity _mapDbEntityToDomainEntity(db.CategoryEntity dbEntity) {
    return CategoryEntity(
      id: dbEntity.id,
      name: dbEntity.name,
      emoji: dbEntity.emoji,
      isIncome: dbEntity.isIncome,
    );
  }

  Future<void> _saveCategoryToLocal(Category category) async {
    final now = DateTime.now();
    final entity = db.CategoryEntity(
      id: category.id,
      name: category.name,
      emoji: category.emoji,
      isIncome: category.isIncome,
      createdAt: now,
      updatedAt: now,
    );
    
    await _databaseService.addCategory(entity);
  }

  Future<void> _updateLocalCategories(List<Category> categories) async {
    for (final category in categories) {
      await _saveCategoryToLocal(category);
    }
  }
} 