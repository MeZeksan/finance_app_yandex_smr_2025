import 'dart:async';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart';
import 'package:finance_app_yandex_smr_2025/features/category/domain/repositories/category_repository.dart';

class MockCategoryRepository implements CategoryRepository {
  static final List<Category> _mockData = [
    // Категории доходов
    Category(
      id: 1,
      name: "Зарплата",
      emoji: "💰",
      isIncome: true,
    ),
    Category(
      id: 2,
      name: "Фриланс",
      emoji: "💻",
      isIncome: true,
    ),
    Category(
      id: 3,
      name: "Инвестиции",
      emoji: "📈",
      isIncome: true,
    ),
    Category(
      id: 4,
      name: "Подработка",
      emoji: "💼",
      isIncome: true,
    ),
    
    // Категории расходов
    Category(
      id: 5,
      name: "Комикс-шоп",
      emoji: "📚",
      isIncome: false,
    ),
    Category(
      id: 6,
      name: "Зоомагазин",
      emoji: "🐾",
      isIncome: false,
    ),
    Category(
      id: 7,
      name: "Кофейня",
      emoji: "☕",
      isIncome: false,
    ),
    Category(
      id: 8,
      name: "Кинотеатр",
      emoji: "🎬",
      isIncome: false,
    ),
    Category(
      id: 9,
      name: "Книжный",
      emoji: "📖",
      isIncome: false,
    ),
    Category(
      id: 10,
      name: "Игровой магазин",
      emoji: "🎮",
      isIncome: false,
    ),
    Category(
      id: 11,
      name: "Пиццерия",
      emoji: "🍕",
      isIncome: false,
    ),
    Category(
      id: 12,
      name: "Суши-бар",
      emoji: "🍱",
      isIncome: false,
    ),
    Category(
      id: 13,
      name: "Спортзал",
      emoji: "🏋️",
      isIncome: false,
    ),
    Category(
      id: 14,
      name: "Магазин музыки",
      emoji: "🎵",
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
