import 'package:equatable/equatable.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_responce/account_responce.dart';

enum AccountStatus { initial, loading, success, failure }

class AccountState extends Equatable {
  final AccountStatus status;
  final AccountResponce? account;
  final String? errorMessage;

  const AccountState({
    this.status = AccountStatus.initial,
    this.account,
    this.errorMessage,
  });

  AccountState copyWith({
    AccountStatus? status,
    AccountResponce? account,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      account: account ?? this.account,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, account, errorMessage];

  bool get isInitial => status == AccountStatus.initial;
  bool get isLoading => status == AccountStatus.loading;
  bool get isSuccess => status == AccountStatus.success;
  bool get isFailure => status == AccountStatus.failure;
} 