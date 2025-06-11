import 'package:finance_app_yandex_smr_2025/models/stat_item/stat_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_responce.freezed.dart';
part 'account_responce.g.dart';

@freezed
abstract class AccountResponce with _$AccountResponce {
  factory AccountResponce({
    required int id, //1
    required String name, // основной счет
    required String balance, //1000.00
    required String currency, // RUB
    required StatItem incomeStats,
    required StatItem expenseStats,
    required DateTime createdAt, // дата
    required DateTime updatedAt,
  }) = _AccountResponce;

  factory AccountResponce.fromJson(Map<String, dynamic> json) =>
      _$AccountResponceFromJson(json);
}
