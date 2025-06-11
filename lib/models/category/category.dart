import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class Category with _$Category {
  factory Category({
    required int id, //1
    required int name, //Зарплата
    required String emoji, //💀
    required bool isIncome, // true
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
