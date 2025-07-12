import 'package:finance_app_yandex_smr_2025/core/database/entities/backup_operation_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/core/network/api_client.dart';
import 'package:finance_app_yandex_smr_2025/core/network/network_service.dart';
import 'package:finance_app_yandex_smr_2025/core/services/backup_service.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';
import 'package:finance_app_yandex_smr_2025/core/database/entities/category_entity.dart' as db;
import 'dart:developer' as developer;

class NetworkCategoryRepository implements CategoryRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final ApiClient _apiClient = ApiClient();
  final NetworkService _networkService = NetworkService();
  final BackupService _backupService = BackupService();

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    developer.log('📋 Получение всех категорий', name: 'NetworkCategoryRepository');

    // Сначала пытаемся синхронизировать ожидающие операции
    if (_networkService.isConnected) {
      developer.log('📡 Синхронизация ожидающих операций', name: 'NetworkCategoryRepository');
      await _backupService.syncPendingOperations();
      
      // ВСЕГДА проверяем сервер в первую очередь
      developer.log('🌐 Запрос категорий с сервера: GET /categories', name: 'NetworkCategoryRepository');
      try {
        final response = await _apiClient.get('/categories');
        if (response.statusCode == 200 && response.data != null) {
          developer.log('✅ Получен ответ от сервера: ${response.data}', name: 'NetworkCategoryRepository');
          
          // API может возвращать либо массив напрямую, либо в оболочке
          List<dynamic> categoriesData;
          if (response.data is List) {
            categoriesData = response.data as List<dynamic>;
          } else if (response.data is Map && response.data['data'] != null) {
            categoriesData = response.data['data'] as List<dynamic>;
          } else {
            developer.log('❌ Неожиданный формат ответа от сервера', name: 'NetworkCategoryRepository');
            categoriesData = [];
          }
          
                      if (categoriesData.isNotEmpty) {
              developer.log('📊 Получено ${categoriesData.length} категорий с сервера', name: 'NetworkCategoryRepository');
              
              // Парсим реальные категории с сервера
              final List<CategoryEntity> categories = [];
              
              for (final categoryJson in categoriesData) {
                if (categoryJson is Map<String, dynamic>) {
                  try {
                    final category = CategoryEntity(
                      id: categoryJson['id'] ?? 0,
                      name: categoryJson['name'] ?? 'Категория',
                      emoji: categoryJson['emoji'] ?? '📝',
                      isIncome: categoryJson['isIncome'] ?? false,
                    );
                    categories.add(category);
                    developer.log('📝 Категория: ID=${category.id}, ${category.name} ${category.emoji} (доход: ${category.isIncome})', name: 'NetworkCategoryRepository');
                  } catch (e) {
                    developer.log('⚠️ Ошибка парсинга категории: $e', name: 'NetworkCategoryRepository');
                  }
                }
              }
              
              if (categories.isNotEmpty) {
                // Сначала очищаем локальную базу и добавляем актуальные категории
                developer.log('🗑️ Очищаем старые категории из локальной базы', name: 'NetworkCategoryRepository');
                try {
                  // Получаем все существующие категории и удаляем их
                  final existingCategories = await _databaseService.getAllCategories();
                  for (final existingCategory in existingCategories) {
                    await _databaseService.deleteCategory(existingCategory.id);
                  }
                } catch (e) {
                  developer.log('⚠️ Ошибка очистки категорий: $e', name: 'NetworkCategoryRepository');
                }
                
                // Обновляем локальную базу новыми категориями
                await _updateLocalCategoriesFromEntities(categories);
                developer.log('💾 ${categories.length} категорий сохранены в локальную базу', name: 'NetworkCategoryRepository');
                return categories;
              }
            } else {
              developer.log('⚠️ Сервер вернул пустой список категорий', name: 'NetworkCategoryRepository');
            }
        } else {
          developer.log('❌ Сервер вернул статус: ${response.statusCode}', name: 'NetworkCategoryRepository');
        }
      } catch (e) {
        developer.log('❌ Ошибка при получении категорий с сервера: $e', name: 'NetworkCategoryRepository');
      }
    } else {
      developer.log('📵 Нет подключения к сети', name: 'NetworkCategoryRepository');
    }

    // Если сервер недоступен или не вернул данных, используем локальную базу
    developer.log('💾 Получение категорий из локальной базы', name: 'NetworkCategoryRepository');
    final localCategories = await _databaseService.getAllCategories();
    
    if (localCategories.isEmpty) {
      developer.log('⚠️ Локальная база пуста, возвращаем пустой список', name: 'NetworkCategoryRepository');
      return [];
    }
    
    developer.log('📊 Найдено ${localCategories.length} категорий в локальной базе', name: 'NetworkCategoryRepository');
    return localCategories.map(_mapDbEntityToDomainEntity).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    developer.log('💰 Получение категорий доходов', name: 'NetworkCategoryRepository');

    // Сначала получаем все категории и фильтруем доходы
    final allCategories = await getAllCategories();
    final incomeCategories = allCategories.where((cat) => cat.isIncome).toList();
    
    developer.log('📊 Найдено ${incomeCategories.length} категорий доходов', name: 'NetworkCategoryRepository');
    return incomeCategories;
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    developer.log('💸 Получение категорий расходов', name: 'NetworkCategoryRepository');

    // Сначала получаем все категории и фильтруем расходы
    final allCategories = await getAllCategories();
    final expenseCategories = allCategories.where((cat) => !cat.isIncome).toList();
    
    developer.log('📊 Найдено ${expenseCategories.length} категорий расходов', name: 'NetworkCategoryRepository');
    return expenseCategories;
  }

  // Дополнительные методы для CRUD операций
  Future<CategoryEntity> createCategory(String name, String emoji, bool isIncome) async {
    // Создаем временную категорию локально с ID = 0 для автогенерации
    final now = DateTime.now();
    final localCategory = db.CategoryEntity(
      id: 0, // Используем 0 для автогенерации ID в ObjectBox
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

  Future<void> _updateLocalCategoriesFromEntities(List<CategoryEntity> categories) async {
    for (final category in categories) {
      final now = DateTime.now();
      
      // Проверяем, существует ли уже категория с таким ID
      final existingCategory = await _databaseService.getCategoryById(category.id);
      
      final dbEntity = db.CategoryEntity(
        id: existingCategory != null ? category.id : 0, // Используем реальный ID если категория уже существует, иначе 0
        name: category.name,
        emoji: category.emoji,
        isIncome: category.isIncome,
        createdAt: existingCategory?.createdAt ?? now,
        updatedAt: now,
      );
      
      try {
        await _databaseService.addCategory(dbEntity);
        developer.log('✅ Категория сохранена: ID=${category.id}, ${category.name}', name: 'NetworkCategoryRepository');
      } catch (e) {
        developer.log('⚠️ Ошибка сохранения категории ${category.name}: $e', name: 'NetworkCategoryRepository');
        
        // Если ошибка с ID, пробуем создать новую запись
        try {
          final newDbEntity = db.CategoryEntity(
            id: 0, // Автогенерация ID
            name: category.name,
            emoji: category.emoji,
            isIncome: category.isIncome,
            createdAt: now,
            updatedAt: now,
          );
          await _databaseService.addCategory(newDbEntity);
          developer.log('✅ Категория создана с новым ID: ${category.name}', name: 'NetworkCategoryRepository');
        } catch (e2) {
          developer.log('❌ Критическая ошибка сохранения категории ${category.name}: $e2', name: 'NetworkCategoryRepository');
        }
      }
    }
  }


} 