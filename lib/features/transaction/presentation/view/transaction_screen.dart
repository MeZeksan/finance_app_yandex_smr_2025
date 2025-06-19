import 'package:finance_app_yandex_smr_2025/features/account/data/models/account_brief/account_brief.dart';
import 'package:finance_app_yandex_smr_2025/features/category/data/models/category.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  final TransactionRepository repository;

  const TransactionsScreen({
    super.key,
    required this.isIncome, required this.repository,

  });

  @override
  Widget build(BuildContext context) {
    return TransactionsView(isIncome: isIncome);
  }
}

class TransactionsView extends StatelessWidget {
  final bool isIncome;

  const TransactionsView({
    super.key,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    // Фиксированный список транзакций
    final transactions = [
      TransactionResponce(
        id: 1,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        balance: '24334',
        currency: 'RUB',
      ),
      category: Category(id: 1, name: 'Зарплата', emoji: '💰', isIncome: true),
      amount: '50000.00',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      comment: 'Зарплата за месяц',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionResponce(
       id: 2,
      account: AccountBrief(
        id: 1,
        name: 'Основной счет',
        currency: 'RUB',
        balance: '34356',
      ),
      category: Category(id: 2, name: 'Продукты', emoji: '🛒', isIncome: false),
      amount: '2500.50',
      transactionDate: DateTime.now().subtract(const Duration(hours: 6)),
      comment: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    // Фильтруем транзакции по типу (доход/расход)
    final filteredTransactions = transactions
        .where((t) => t.category.isIncome == isIncome)
        .toList();

    // Считаем общую сумму
    final totalAmount = filteredTransactions.fold(
      0.0,
      (sum, t) => sum + (double.tryParse(t.amount) ?? 0.0));
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedTotalAmount = '${formatter.format(totalAmount.round())} ₽';

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFb2AE881),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      isIncome ? 'Доходы сегодня' : 'Расходы сегодня',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Обновление данных (пустая функция)
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFF1D1B20),
                  ),
                ),
              ],
            ),
          ),
        
          Expanded(
            child: Column(
              children: [
                // Блок "Всего"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4FAE6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        
                        'Всего',
                        style: TextStyle(
                          color: Color(0xFF1D1B20),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formattedTotalAmount,
                        style: const TextStyle(
                          color: Color(0xFF1D1B20),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12,),
                // Список транзакций
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isIncome ? Icons.trending_up : Icons.trending_down,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isIncome 
                                    ? 'Нет доходов за сегодня'
                                    : 'Нет расходов за сегодня',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = filteredTransactions[index];
                            return TransactionTile(transaction: transaction);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),

        onPressed: () {
          // TODO: Навигация к экрану добавления транзакции
        },
        backgroundColor: const Color(0xFFb2AE881),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
