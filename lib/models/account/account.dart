import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  factory Account({
    required int id, //1
    required int userId, //1
    required String name, // основной счет
    required String balance, //1000.00
    required String currency, // RUB
    required DateTime createdAt, // дата
    required DateTime updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
