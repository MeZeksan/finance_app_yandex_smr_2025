import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'transaction_event.bloc.dart';
part 'transaction_state.bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  TransactionBloc({required TransactionRepository repository})
      : _repository = repository,
        super(TransactionInitial()) {
    on<LoadTodayTransactions>(_onLoadTodayTransactions);
  }

  Future<void> _onLoadTodayTransactions(
    LoadTodayTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());

      // Получаем начало и конец текущего дня
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Теперь просто используем метод из интерфейса - без проверки типов!
      final filteredTransactions = await _repository.getTransactionsByDateAndType(
        dateFrom: startOfDay,
        dateTo: endOfDay,
        isIncome: event.isIncome,
      );

      // Сортируем по дате (новые сверху)
      filteredTransactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      // Вычисляем общую сумму
      double total = 0.0;
      for (final transaction in filteredTransactions) {
        total += double.tryParse(transaction.amount) ?? 0.0;
      }

      // Форматируем сумму
      final formatter = NumberFormat('#,##0', 'ru_RU');
      final totalFormatted = '${formatter.format(total.round())} ₽';

      emit(TransactionLoaded(
        transactions: filteredTransactions,
        totalAmount: totalFormatted,
      ));
    } catch (e) {
      emit(TransactionError(message: 'Ошибка загрузки транзакций: $e'));
    }
  }
}