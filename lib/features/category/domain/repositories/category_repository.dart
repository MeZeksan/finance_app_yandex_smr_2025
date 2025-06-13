import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<List<CategoryEntity>> getIncomeCategories();
  Future<List<CategoryEntity>> getExpenseCategories();
}
