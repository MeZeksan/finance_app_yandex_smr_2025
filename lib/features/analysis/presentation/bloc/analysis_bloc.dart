import 'package:finance_app_yandex_smr_2025/features/analysis/data/models/category_analysis.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/bloc/analysis_event.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/bloc/analysis_state.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final TransactionRepository _repository;

  AnalysisBloc({required TransactionRepository repository})
      : _repository = repository,
        super(AnalysisState()) {
    on<AnalysisInitialized>(_onInitialized);
    on<AnalysisRefreshed>(_onRefreshed);
    on<AnalysisDateRangeChanged>(_onDateRangeChanged);
  }

  Future<void> _onInitialized(
    AnalysisInitialized event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(state.copyWith(
      status: AnalysisStatus.loading,
      isIncome: event.isIncome,
    ));

    await _loadTransactions(emit);
  }

  Future<void> _onRefreshed(
    AnalysisRefreshed event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(state.copyWith(status: AnalysisStatus.loading));
    await _loadTransactions(emit);
  }

  Future<void> _onDateRangeChanged(
    AnalysisDateRangeChanged event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(state.copyWith(
      status: AnalysisStatus.loading,
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    await _loadTransactions(emit);
  }

  Future<void> _loadTransactions(Emitter<AnalysisState> emit) async {
    try {
      final transactions = await _repository.getTransactionsByDateAndType(
        dateFrom: state.startDate,
        dateTo: state.endDate,
        isIncome: state.isIncome,
      );

      if (transactions.isEmpty) {
        emit(state.copyWith(
          status: AnalysisStatus.success,
          categories: [],
          totalAmount: 0,
        ));
        return;
      }

      // Группировка транзакций по названиям категорий (вместо ID)
      final Map<String, List<TransactionResponce>> categorizedTransactions = {};
      double totalAmount = 0;

      for (final transaction in transactions) {
        final categoryName = transaction.category.name;
        if (!categorizedTransactions.containsKey(categoryName)) {
          categorizedTransactions[categoryName] = [];
        }
        categorizedTransactions[categoryName]!.add(transaction);
        
        final amount = double.tryParse(transaction.amount) ?? 0;
        totalAmount += amount;
      }

      // Создание списка анализа по категориям
      final List<CategoryAnalysis> categories = [];
      
      categorizedTransactions.forEach((categoryName, categoryTransactions) {
        // Сортировка транзакций по дате (сначала новые)
        categoryTransactions.sort((a, b) => 
          b.transactionDate.compareTo(a.transactionDate));
        
        // Расчет суммы для категории
        double categoryAmount = 0;
        for (final transaction in categoryTransactions) {
          final amount = double.tryParse(transaction.amount) ?? 0;
          categoryAmount += amount;
        }
        
        // Расчет процента от общей суммы
        final double percentage = totalAmount > 0 ? (categoryAmount / totalAmount) * 100 : 0;
        
        // Создание объекта анализа категории
        categories.add(CategoryAnalysis(
          categoryId: categoryTransactions.first.category.id.toString(),
          categoryName: categoryName,
          emoji: categoryTransactions.first.category.emoji,
          amount: categoryAmount,
          percentage: percentage,
          transactions: categoryTransactions,
        ));
      });
      
      // Сортировка категорий по сумме (по убыванию)
      categories.sort((a, b) => b.amount.compareTo(a.amount));

      emit(state.copyWith(
        status: AnalysisStatus.success,
        categories: categories,
        totalAmount: totalAmount,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AnalysisStatus.failure,
        errorMessage: 'Ошибка загрузки данных: ${error.toString()}',
      ));
    }
  }
} 