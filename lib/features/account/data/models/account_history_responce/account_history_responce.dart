import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_history.dart/account_history.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_history_responce.freezed.dart';
part 'account_history_responce.g.dart';

@freezed
abstract class AccountHistoryResponce with _$AccountHistoryResponce {
  factory AccountHistoryResponce({
    required int accountId, //1
    required String accountName, // основной счет
    required String currency, // USD
    required String currentBalance,
    required AccountHistory history,
  }) = _AccountHistoryResponce;

  factory AccountHistoryResponce.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryResponceFromJson(json);
}
