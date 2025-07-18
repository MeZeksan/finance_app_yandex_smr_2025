import 'package:finance_app_yandex_smr_2025/features/history/presentation/view/history_screen.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/core/services/theme_service.dart';
import 'package:finance_app_yandex_smr_2025/core/services/haptic_service.dart';
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

class TransactionsView extends StatefulWidget {
  final bool isIncome;
  final String buttonTag;
  const TransactionsView({
    super.key,
    required this.isIncome,
    required this.buttonTag,
  });

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  late ThemeService _themeService;
  late HapticService _hapticService;

  @override
  void initState() {
    super.initState();
    _themeService = ServiceLocator.themeService;
    _hapticService = ServiceLocator.hapticService;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;

    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _themeService.backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeService.headerColor,
            ),
            child: Padding(
              padding:  EdgeInsets.only(top:topPadding),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    widget.isIncome ? 'Доходы сегодня' : 'Расходы сегодня',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _themeService.textColor,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryScreen(isIncome: widget.isIncome)),
                        );
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: _themeService.textColor,
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
                  return Center(
                    child: CircularProgressIndicator(
                      color: _themeService.headerColor,
                    ),
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
                            // Хаптик фидбек при нажатии на кнопку повтора
                            _hapticService.mediumImpact();
                            
                            context.read<TransactionBloc>().add(
                              LoadTodayTransactions(isIncome: widget.isIncome),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _themeService.headerColor,
                            foregroundColor: Colors.white,
                          ),
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
                        decoration: BoxDecoration(
                          color: _themeService.containerColor,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Всего',
                              style: TextStyle(
                                color: _themeService.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              state.totalAmount,
                              style: TextStyle(
                                color: _themeService.textColor,
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
                                      widget.isIncome ? Icons.trending_up : Icons.trending_down,
                                      size: 64,
                                      color: _themeService.textColor.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.isIncome 
                                          ? 'Нет доходов за сегодня'
                                          : 'Нет расходов за сегодня',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _themeService.textColor.withValues(alpha: 0.6),
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
                                        LoadTodayTransactions(isIncome: widget.isIncome),
                                      );
                                    },
                                  );
                                },
                              )
                      ),
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: _themeService.headerColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        heroTag: widget.buttonTag,
        shape: const CircleBorder(),
        onPressed: () async {
          // Хаптик фидбек при нажатии на кнопку добавления
          _hapticService.mediumImpact();
          
          final result = await TransactionScreen.show(
            context,
            widget.isIncome,
            ServiceLocator.transactionRepository,
          );
          if (result == true) {
            // Refresh transactions after creating new one
            context.read<TransactionBloc>().add(
              LoadTodayTransactions(isIncome: widget.isIncome),
            );
          }
        },
        backgroundColor: _themeService.headerColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
        );
      },
    );
  }
}