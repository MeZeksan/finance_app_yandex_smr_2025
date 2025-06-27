import 'package:finance_app_yandex_smr_2025/core/database/entities/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/core/database/services/database_service.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart' as domain;
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';

class DbCategoryRepository implements CategoryRepository {
  final DatabaseService _databaseService;

  DbCategoryRepository({required DatabaseService databaseService}) : _databaseService = databaseService;

  // Конвертация между Entity и моделью
  CategoryEntity _mapToDbEntity(Category category) {
    return CategoryEntity(
      id: category.id,
      name: category.name,
      emoji: category.emoji,
      isIncome: category.isIncome,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Category _mapFromDbEntity(CategoryEntity entity) {
    return Category(
      id: entity.id,
      name: entity.name,
      emoji: entity.emoji,
      isIncome: entity.isIncome,
    );
  }

  domain.CategoryEntity _mapToDomainEntity(CategoryEntity entity) {
    return domain.CategoryEntity(
      id: entity.id,
      name: entity.name,
      emoji: entity.emoji,
      isIncome: entity.isIncome,
    );
  }

  @override
  Future<List<domain.CategoryEntity>> getAllCategories() async {
    final categories = await _databaseService.getAllCategories();
    return categories.map(_mapToDomainEntity).toList();
  }

  @override
  Future<List<domain.CategoryEntity>> getIncomeCategories() async {
    final categories = await _databaseService.getCategoriesByType(true);
    return categories.map(_mapToDomainEntity).toList();
  }

  @override
  Future<List<domain.CategoryEntity>> getExpenseCategories() async {
    final categories = await _databaseService.getCategoriesByType(false);
    return categories.map(_mapToDomainEntity).toList();
  }

  // Дополнительные методы для работы с базой данных
  Future<domain.CategoryEntity?> getCategoryById(int id) async {
    final category = await _databaseService.getCategoryById(id);
    if (category == null) return null;
    return _mapToDomainEntity(category);
  }

  Future<domain.CategoryEntity> createCategory(String name, String emoji, bool isIncome) async {
    final now = DateTime.now();
    final category = CategoryEntity(
      name: name,
      emoji: emoji,
      isIncome: isIncome,
      createdAt: now,
      updatedAt: now,
    );
    
    final id = await _databaseService.addCategory(category);
    
    return domain.CategoryEntity(
      id: id,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
    );
  }

  Future<bool> deleteCategory(int id) async {
    return await _databaseService.deleteCategory(id);
  }

  Future<domain.CategoryEntity> updateCategory(int id, String name, String emoji, bool isIncome) async {
    final existingCategory = await _databaseService.getCategoryById(id);
    if (existingCategory == null) {
      throw Exception('Category not found');
    }
    
    final updatedCategory = CategoryEntity(
      id: id,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
      createdAt: existingCategory.createdAt,
      updatedAt: DateTime.now(),
    );
    
    await _databaseService.addCategory(updatedCategory);
    
    return domain.CategoryEntity(
      id: id,
      name: name,
      emoji: emoji,
      isIncome: isIncome,
    );
  }
} 