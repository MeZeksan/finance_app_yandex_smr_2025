import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_state.freezed.dart';
part 'account_state.g.dart';

@freezed
abstract class AccountState with _$AccountState {
  factory AccountState({
    required int id, //1
    required String name, // основной счет
    required String balance, //1000.00
    required String currency, // RUB
  }) = _AccountState;

  factory AccountState.fromJson(Map<String, dynamic> json) =>
      _$AccountStateFromJson(json);
}
