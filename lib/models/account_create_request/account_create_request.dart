import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_create_request.freezed.dart';
part 'account_create_request.g.dart';

@freezed
abstract class AccountCreateRequest with _$AccountCreateRequest {
  factory AccountCreateRequest({
    required String name, //основной счет
    required String balance, // 1000ю00
    required String currency, // RUB
  }) = _AccountCreateRequest;

  factory AccountCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountCreateRequestFromJson(json);
}
