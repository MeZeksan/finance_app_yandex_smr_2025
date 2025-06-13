import 'package:finance_app_yandex_smr_2025/features/category/domain/entity/category_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  factory Category({
    required int id, //1
    required String name, //Зарплата
    required String emoji, //💀
    required bool isIncome, // true
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  //благодаря этому можно добавлять кастомные конструкторы. например toEntity
  const Category._();

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        emoji: emoji,
        isIncome: isIncome,
      );
}
