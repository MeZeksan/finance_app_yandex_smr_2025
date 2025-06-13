import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_request.freezed.dart';
part 'transaction_request.g.dart';

@freezed
abstract class TransactionRequest with _$TransactionRequest {
  factory TransactionRequest({
    required int accountId, //1
    required int categoryId, //1
    required String amount, // 500.00
    required DateTime transactionDate,
    required String? comment, // может быть null, а так "Зарплата за месяц"
  }) = _TransactionRequest;

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);
}
