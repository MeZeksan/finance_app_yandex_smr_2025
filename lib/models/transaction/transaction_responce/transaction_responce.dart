import 'package:finance_app_yandex_smr_2025/models/account/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/models/category/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_responce.freezed.dart';
part 'transaction_responce.g.dart';

@freezed
abstract class TransactionResponce with _$TransactionResponce {
  factory TransactionResponce({
    required int id, //1
    required AccountBrief account,
    required Category category,
    required String amount, // 500.00
    required DateTime transactionDate,
    required String? comment, // может быть null, а так "Зарплата за месяц"
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionResponce;

  factory TransactionResponce.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponceFromJson(json);
}
