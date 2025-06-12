import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_update_request.freezed.dart';
part 'account_update_request.g.dart';

@freezed
abstract class AccountUpdateRequest with _$AccountUpdateRequest {
  factory AccountUpdateRequest({
    required String name, //новое название счета
    required String balance, // 1000.00
    required String currency, // RUB
  }) = _AccountUpdateRequest;

  factory AccountUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$AccountUpdateRequestFromJson(json);
}
