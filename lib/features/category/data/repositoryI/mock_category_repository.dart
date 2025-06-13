import 'dart:async';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';

class MockCategoryRepository implements CategoryRepository {
  static final List<Category> _mockData = [
    Category(
      id: 1,
      name: "Зарплата",
      emoji: "💼",
      isIncome: true,
    ),
    Category(
      id: 2,
      name: "Дивиденды",
      emoji: "📈",
      isIncome: true,
    ),
    Category(
      id: 3,
      name: "Продукты",
      emoji: "🍎",
      isIncome: false,
    ),
    Category(
      id: 4,
      name: "Транспорт",
      emoji: "🚗",
      isIncome: false,
    ),
    Category(
      id: 5,
      name: "Подарок",
      emoji: "🎁",
      isIncome: true,
    ),
    Category(
      id: 6,
      name: "Кафе",
      emoji: "☕",
      isIncome: false,
    ),
  ];

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    return _mockData.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getIncomeCategories() async {
    return _mockData
        .where((model) => model.isIncome)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<CategoryEntity>> getExpenseCategories() async {
    return _mockData
        .where((model) => !model.isIncome)
        .map((model) => model.toEntity())
        .toList();
  }
}
