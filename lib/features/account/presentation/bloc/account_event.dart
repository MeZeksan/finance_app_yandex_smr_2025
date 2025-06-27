import 'package:equatable/equatable.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_update_request/account_update_request.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccount extends AccountEvent {
  final int accountId;

  const LoadAccount({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class UpdateAccount extends AccountEvent {
  final int accountId;
  final AccountUpdateRequest request;

  const UpdateAccount({
    required this.accountId,
    required this.request,
  });

  @override
  List<Object?> get props => [accountId, request];
} 