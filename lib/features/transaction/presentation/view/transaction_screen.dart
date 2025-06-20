import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/bloc/transaction.bloc.dart';

import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  final TransactionRepository repository;

  const TransactionsScreen({
    super.key,
    required this.isIncome,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(repository: repository)
        ..add(LoadTodayTransactions(isIncome: isIncome)),
      child: TransactionsView(isIncome: isIncome),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: Column(
        children: [
          // Header
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
                    
                    context.read<TransactionBloc>().add(
                      LoadTodayTransactions(isIncome: isIncome),
                    );
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFF1D1B20),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
            
                if (state is TransactionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<TransactionBloc>().add(
                              LoadTodayTransactions(isIncome: isIncome),
                            );
                          },
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is TransactionLoaded) {
                  return Column(
                    children: [
                      // Контейнер "Всего"
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4FAE6),
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
                              state.totalAmount,
                              style: const TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: state.transactions.isEmpty
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
                                itemCount: state.transactions.length,
                                itemBuilder: (context, index) {
                                  return TransactionTile(
                                    transaction: state.transactions[index],
                                    isFirst: index == 0,
                                    isLast: index == state.transactions.length - 1,
                                  );
                                },
                              )
                      ),
                      
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
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