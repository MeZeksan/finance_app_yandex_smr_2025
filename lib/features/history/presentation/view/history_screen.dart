import 'package:auto_route/annotations.dart';
import 'package:finance_app_yandex_smr_2025/features/history/presentation/bloc/history_bloc.dart';
import 'package:finance_app_yandex_smr_2025/features/history/presentation/widgets/widgets.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/mock_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';


@RoutePage()
class HistoryScreen extends StatelessWidget {
  final bool isIncome;

  const HistoryScreen({
    super.key,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final TransactionRepository repository = MockTransactionRepository();
    return BlocProvider(
      create: (context) => HistoryBloc(repository: repository)
        ..add(HistoryInitialized(isIncome: isIncome)),
      child: HistoryView(isIncome: isIncome));
  }
}

class HistoryView extends StatefulWidget {
  final bool isIncome;

  const HistoryView({
    super.key,
    required this.isIncome,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    try {
      // Initialize date formatting for multiple locales
      await initializeDateFormatting('ru_RU', null);
      await initializeDateFormatting('en_US', null);
      await initializeDateFormatting(); // Initialize default locale
      
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
      }
    } catch (e) {
      // If locale initialization fails, still allow the widget to render
      // but with basic formatting
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    if (!_isLocaleInitialized) return;
    
    final historyBloc = context.read<HistoryBloc>();
    final currentState = historyBloc.state;
    
    final DateTime now = DateTime.now().add(Duration(days: 51));
    final DateTime targetDate = isStartDate ? currentState.startDate : currentState.endDate;
    final DateTime initialDate = targetDate.isAfter(now) ? now : targetDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFb2AE881),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      DateTime newStartDate = currentState.startDate;
      DateTime newEndDate = currentState.endDate;
      
      if (isStartDate) {
        newStartDate = DateTime(picked.year, picked.month, picked.day);
        if (newStartDate.isAfter(currentState.endDate)) {
          newEndDate = newStartDate;
        }
      } else {
        newEndDate = DateTime(picked.year, picked.month, picked.day);
        if (newEndDate.isBefore(currentState.startDate)) {
          newStartDate = newEndDate;
        }
      }
      
      historyBloc.add(HistoryDateRangeChanged(
        startDate: newStartDate,
        endDate: newEndDate,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;
    
    if (!_isLocaleInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFFEF7FF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return Column(
            children: [
              HistoryHeader(topPadding: topPadding),

              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4FAE6),
                ),
                child: Column(
                  children: [
                    // Start Date
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4FAE6),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Начало',
                              style: TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  state.formattedStartDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1D1B20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFF1D1B20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4FAE6),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Конец',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF1D1B20),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  state.formattedEndDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1D1B20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Color(0xFF1D1B20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4FAE6),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Сумма',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1D1B20),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            state.formattedTotalAmount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1D1B20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),

              
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.isFailure) {
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
              state.errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<HistoryBloc>().add(const HistoryRefreshed());
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: state.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        state.isIncome ? Icons.trending_up : Icons.trending_down,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.isIncome 
                            ? 'Нет доходов за выбранный период'
                            : 'Нет расходов за выбранный период',
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
                    final transaction = state.transactions[index];
                    return HistoryTile(
                      transaction: transaction,
                      showDate: state.selectedPeriod != DatePeriod.day,
                      isFirst: index == 0,
                      isLast: index == state.transactions.length - 1,
                      onChanged: () {
                        // Refresh the history when a transaction is edited
                        context.read<HistoryBloc>().add(const HistoryRefreshed());
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
