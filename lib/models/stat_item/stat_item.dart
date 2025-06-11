import 'package:freezed_annotation/freezed_annotation.dart';

part 'stat_item.freezed.dart';
part 'stat_item.g.dart';

@freezed
abstract class StatItem with _$StatItem {
  factory StatItem({
    required int categoryId, //1
    required int categoryName, //Зарплата
    required String emoji, //💀
    required String amount, //5000.00
  }) = _StatItem;

  factory StatItem.fromJson(Map<String, dynamic> json) =>
      _$StatItemFromJson(json);
}
