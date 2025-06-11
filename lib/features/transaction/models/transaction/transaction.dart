import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class Transaction with _$Transaction {
  factory Transaction({
    required int id, //1
    required int accountId, //1
    required int categoryId, //1
    required String amount, // 500.00
    required DateTime transactionDate,
    required String? comment, // может быть null, а так "Зарплата за месяц"
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
