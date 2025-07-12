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
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    var totalIncome = 0.0;
    var totalExpense = 0.0;
    var currentBalance = 0.0; // Начинаем с нулевого баланса
    
    // Рассчитываем суммы за месяц
    for (int day = 1; day <= lastDayOfMonth; day++) {
      final isIncome = day % 6 == 0 || day % 9 == 0;
      final base = isIncome ? 35000.0 : 12000.0;
      final variation = isIncome ? 20000.0 : 15000.0;
      final mod = (day % 8) - 4;
      final amount = base + variation * mod.abs() / 4;
      
      if (isIncome) {
        totalIncome += amount;
        currentBalance += amount;
      } else {
        totalExpense += amount;
        currentBalance -= amount;
      }
    }

    _accounts[1] = AccountResponce(
      id: 1,
      name: 'Основной счет',
      balance: currentBalance.toStringAsFixed(2),
      currency: 'RUB',
      incomeStats: StatItem(
        categoryId: 1,
        categoryName: 'Зарплата и фриланс',
        emoji: '💰',
        amount: totalIncome.toStringAsFixed(2),
      ),
      expenseStats: StatItem(
        categoryId: 2,
        categoryName: 'Развлечения и хобби',
        emoji: '🎮',
        amount: totalExpense.toStringAsFixed(2),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<AccountResponce> getAccountById(int accountId) async {
    // Симуляция задержки сети
    await Future.delayed(const Duration(milliseconds: 500));

    // Возвращаем заранее созданный счет или создаем дефолтный
    final existingAccount = _accounts[accountId];
    if (existingAccount != null) {
      return existingAccount;
    }
    
    // Создаем дефолтный счет для любого другого ID
    return AccountResponce(
      id: accountId,
      name: 'Основной счет',
      balance: '0.00',
      currency: 'RUB',
      incomeStats: StatItem(
        categoryId: 1,
        categoryName: 'Доходы',
        emoji: '💰',
        amount: '0.00',
      ),
      expenseStats: StatItem(
        categoryId: 2,
        categoryName: 'Расходы',
        emoji: '💸',
        amount: '0.00',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
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
