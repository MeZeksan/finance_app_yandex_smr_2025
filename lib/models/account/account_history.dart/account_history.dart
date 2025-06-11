import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finance_app_yandex_smr_2025/models/account/account_state/account_state.dart';

part 'account_history.freezed.dart';
part 'account_history.g.dart';

@freezed
abstract class AccountHistory with _$AccountHistory {
  factory AccountHistory({
    required int id, //1
    required int accountId, // 1
    required String changeType, //MODIFICATION
    required AccountState previousState,
    required AccountState newState,
    required DateTime changeTimestamp,
    required DateTime createdAt,
  }) = _AccountHistory;

  factory AccountHistory.fromJson(Map<String, dynamic> json) =>
      _$AccountHistoryFromJson(json);
}
