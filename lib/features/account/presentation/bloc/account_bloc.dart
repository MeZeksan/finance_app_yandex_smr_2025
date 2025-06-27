import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/bloc/account_event.dart';
import 'package:finance_app_yandex_smr_2025/features/account/presentation/bloc/account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final BankAccountRepository _repository;

  AccountBloc({required BankAccountRepository repository})
      : _repository = repository,
        super(const AccountState()) {
    on<LoadAccount>(_onLoadAccount);
    on<UpdateAccount>(_onUpdateAccount);
  }

  Future<void> _onLoadAccount(
    LoadAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.loading));

    try {
      final account = await _repository.getAccountById(event.accountId);
      
      if (account != null) {
        emit(state.copyWith(
          status: AccountStatus.success,
          account: account,
        ));
      } else {
        emit(state.copyWith(
          status: AccountStatus.failure,
          errorMessage: 'Счет не найден',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: 'Ошибка загрузки счета: ${error.toString()}',
      ));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: AccountStatus.loading));

    try {
      final updatedAccount = await _repository.updateAccount(
        event.accountId,
        event.request,
      );

      emit(state.copyWith(
        status: AccountStatus.success,
        account: updatedAccount,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: 'Ошибка обновления счета: ${error.toString()}',
      ));
    }
  }
} 