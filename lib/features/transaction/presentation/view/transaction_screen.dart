import 'package:finance_app_yandex_smr_2025/features/history/presentation/view/history_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/mock_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/bloc/transaction.bloc.dart';

import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  final TransactionRepository repository;
  final String buttonTag;

  const TransactionsScreen({
    super.key,
    required this.isIncome,
    required this.repository, 
    required this.buttonTag,

  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(repository: repository)
        ..add(LoadTodayTransactions(isIncome: isIncome)),
      child: TransactionsView(isIncome: isIncome, buttonTag: buttonTag,),
    );
  }
}

class TransactionsView extends StatelessWidget {
  final bool isIncome;
  final String buttonTag;
  const TransactionsView({
    super.key,
    required this.isIncome,
    required this.buttonTag,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;

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
            child: Padding(
              padding:  EdgeInsets.only(top:topPadding),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    isIncome ? 'Доходы сегодня' : 'Расходы сегодня',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryScreen(isIncome: isIncome)),
                        );
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ),
                ],
              ),
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
                                padding: EdgeInsets.zero,
                                itemCount: state.transactions.length,
                                itemBuilder: (context, index) {
                                  return TransactionTile(
                                    transaction: state.transactions[index],
                                    isFirst: index == 0,
                                    isLast: index == state.transactions.length - 1,
                                    onChanged: () {
                                      // Refresh the transactions when one is edited
                                      context.read<TransactionBloc>().add(
                                        LoadTodayTransactions(isIncome: isIncome),
                                      );
                                    },
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
        heroTag: buttonTag,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await TransactionScreen.show(
            context,
            isIncome,
            MockTransactionRepository(),
          );
          if (result == true) {
            // Refresh transactions after creating new one
            context.read<TransactionBloc>().add(
              LoadTodayTransactions(isIncome: isIncome),
            );
          }
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