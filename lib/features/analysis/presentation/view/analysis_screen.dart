import 'package:auto_route/annotations.dart';
import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/bloc/analysis_bloc.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/bloc/analysis_event.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/bloc/analysis_state.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/view/category_transactions_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/date_symbol_data_local.dart';

@RoutePage()
class AnalysisScreen extends StatelessWidget {
  final bool isIncome;

  const AnalysisScreen({
    super.key,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalysisBloc(
        repository: ServiceLocator.transactionRepository,
      )..add(AnalysisInitialized(isIncome: isIncome)),
      child: AnalysisView(isIncome: isIncome),
    );
  }
}

class AnalysisView extends StatefulWidget {
  final bool isIncome;

  const AnalysisView({
    super.key,
    required this.isIncome,
  });

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('ru_RU');
    if (mounted) {
      setState(() {
        _isLocaleInitialized = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final state = context.read<AnalysisBloc>().state;
    final initialDate = isStartDate ? state.startDate : state.endDate;
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);

    // Используем стандартный showDatePicker с локализацией
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru', 'RU'),
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

    if (pickedDate != null && mounted) {
      if (isStartDate) {
        context.read<AnalysisBloc>().add(
          AnalysisDateRangeChanged(
            startDate: pickedDate,
            endDate: state.endDate,
          ),
        );
      } else {
        context.read<AnalysisBloc>().add(
          AnalysisDateRangeChanged(
            startDate: state.startDate,
            endDate: pickedDate,
          ),
        );
      }
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
      body: BlocBuilder<AnalysisBloc, AnalysisState>(
        builder: (context, state) {
          return Column(
            children: [
              AnalysisHeader(topPadding: topPadding),

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
                              'Период: начало',
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
                              'Период: конец',
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

  Widget _buildContent(BuildContext context, AnalysisState state) {
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
                context.read<AnalysisBloc>().add(const AnalysisRefreshed());
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      CategoryPieChart(
                        categories: state.categories,
                        totalAmount: state.totalAmount,
                        animate: true,
                        key: ValueKey('${state.startDate.toIso8601String()}_${state.endDate.toIso8601String()}_${state.isIncome}'),
                      ),
                      ListView.builder(
                  padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return CategoryAnalysisTile(
                      category: category,
                      isFirst: index == 0,
                      isLast: index == state.categories.length - 1,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CategoryTransactionsScreen(
                              category: category,
                            ),
                          ),
                        );
                      },
                    );
                  },
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
} 