import 'dart:async';

import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_responce/account_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_update_request/account_update_request.dart';
import 'package:finance_app_yandex_smr_2025/features/account/data/models/stat_item/stat_item.dart';
import 'package:finance_app_yandex_smr_2025/features/account/domain/repository/bank_account_repository.dart';

class MockBankAccountRepository implements BankAccountRepository {
  final Map<int, AccountResponce> _accounts = {};

  MockBankAccountRepository() {
    _initializeWithMockData();
  }

  void _initializeWithMockData() {
    _accounts[1] = AccountResponce(
      id: 1,
      name: 'Основной счет',
      balance: '50000.00',
      currency: 'RUB',
      incomeStats: StatItem(
        categoryId: 1,
        categoryName: 'Зарплата',
        emoji: '💰',
        amount: '80000.00',
      ),
      expenseStats: StatItem(
        categoryId: 2,
        categoryName: 'Продукты',
        emoji: '🛒',
        amount: '30000.00',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<AccountResponce?> getAccountById(int accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _accounts[accountId];
  }

  @override
  Future<AccountResponce> updateAccount(
    int accountId,
    AccountUpdateRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final existingAccount = _accounts[accountId];
    if (existingAccount == null) {
      throw Exception('Account with id $accountId not found');
    }

    final updatedAccount = existingAccount.copyWith(
      name: request.name,
      balance: request.balance,
      currency: request.currency,
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updatedAccount;
    return updatedAccount;
  }
}
