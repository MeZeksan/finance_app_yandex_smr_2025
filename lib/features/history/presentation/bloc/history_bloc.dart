import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

enum DatePeriod {
  day,
  week,
  month,
  year,
  custom,
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final TransactionRepository _repository;

  HistoryBloc({required TransactionRepository repository})
      : _repository = repository,
        super(HistoryState()) {
    on<HistoryInitialized>(_onHistoryInitialized);
    on<HistoryDateRangeChanged>(_onHistoryDateRangeChanged);
    on<HistoryRefreshed>(_onHistoryRefreshed);
    on<HistoryTransactionTypeChanged>(_onHistoryTransactionTypeChanged);
    on<HistoryPeriodChanged>(_onHistoryPeriodChanged);
  }

  Future<void> _onHistoryInitialized(
    HistoryInitialized event,
    Emitter<HistoryState> emit,
  ) async {
    // Устанавливаем период по умолчанию: месяц
    final dateRange = _getDateRangeForPeriod(DatePeriod.month);

    emit(state.copyWith(
      startDate: dateRange.start,
      endDate: dateRange.end,
      isIncome: event.isIncome,
      selectedPeriod: DatePeriod.month,
      status: HistoryStatus.loading,
    ));

    await _loadTransactions(emit);
  }

  Future<void> _onHistoryPeriodChanged(
    HistoryPeriodChanged event,
    Emitter<HistoryState> emit,
  ) async {
    DateRange dateRange;
    
    if (event.period == DatePeriod.custom) {
      // Для кастомного периода используем текущие даты
      dateRange = DateRange(start: state.startDate, end: state.endDate);
    } else {
      dateRange = _getDateRangeForPeriod(event.period);
    }

    emit(state.copyWith(
      selectedPeriod: event.period,
      startDate: dateRange.start,
      endDate: dateRange.end,
      status: HistoryStatus.loading,
    ));

    await _loadTransactions(emit);
  }

  Future<void> _onHistoryDateRangeChanged(
    HistoryDateRangeChanged event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
      selectedPeriod: DatePeriod.custom,
      status: HistoryStatus.loading,
    ));

    await _loadTransactions(emit);
  }

  Future<void> _onHistoryRefreshed(
    HistoryRefreshed event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    await _loadTransactions(emit);
  }

  Future<void> _onHistoryTransactionTypeChanged(
    HistoryTransactionTypeChanged event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(
      isIncome: event.isIncome,
      status: HistoryStatus.loading,
    ));

    await _loadTransactions(emit);
  }

  DateRange _getDateRangeForPeriod(DatePeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case DatePeriod.day:
        return DateRange(
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        );
      
      case DatePeriod.week:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateRange(start: startOfWeek, end: endOfWeek);
      
      case DatePeriod.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
        return DateRange(start: startOfMonth, end: endOfMonth);
      
      case DatePeriod.year:
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year + 1, 1, 1).subtract(const Duration(seconds: 1));
        return DateRange(start: startOfYear, end: endOfYear);
      
      case DatePeriod.custom:
        return DateRange(start: today.subtract(const Duration(days: 30)), end: today);
    }
  }

  Future<void> _loadTransactions(Emitter<HistoryState> emit) async {
    try {
      // Устанавливаем время для начала и конца периода
      final startOfPeriod = DateTime(
        state.startDate.year,
        state.startDate.month,
        state.startDate.day,
        0, 0, 0,
      );
      
      final endOfPeriod = DateTime(
        state.endDate.year,
        state.endDate.month,
        state.endDate.day,
        23, 59, 59,
      );

      final transactions = await _repository.getTransactionsByDateAndType(
        dateFrom: startOfPeriod,
        dateTo: endOfPeriod,
        isIncome: state.isIncome,
      );

      // Сортируем по дате (новые сверху)
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      // Вычисляем общую сумму
      final total = _calculateTotal(transactions);

      emit(state.copyWith(
        transactions: transactions,
        totalAmount: total,
        status: HistoryStatus.success,
        errorMessage: '',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: 'Ошибка загрузки транзакций: ${error.toString()}',
      ));
    }
  }

  double _calculateTotal(List<TransactionResponce> transactions) {
    return transactions.fold(0.0, (sum, transaction) {
      return sum + (double.tryParse(transaction.amount) ?? 0.0);
    });
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}

// Events
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryInitialized extends HistoryEvent {
  final bool isIncome;

  const HistoryInitialized({required this.isIncome});

  @override
  List<Object?> get props => [isIncome];
}

class HistoryDateRangeChanged extends HistoryEvent {
  final DateTime startDate;
  final DateTime endDate;

  const HistoryDateRangeChanged({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class HistoryRefreshed extends HistoryEvent {
  const HistoryRefreshed();
}

class HistoryTransactionTypeChanged extends HistoryEvent {
  final bool isIncome;

  const HistoryTransactionTypeChanged({required this.isIncome});

  @override
  List<Object?> get props => [isIncome];
}

class HistoryPeriodChanged extends HistoryEvent {
  final DatePeriod period;

  const HistoryPeriodChanged({required this.period});

  @override
  List<Object?> get props => [period];
}

// State
enum HistoryStatus {
  initial,
  loading,
  success,
  failure,
}

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<TransactionResponce> transactions;
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isIncome;
  final String errorMessage;
  final DatePeriod selectedPeriod;

  HistoryState({
    this.status = HistoryStatus.initial,
    this.transactions = const [],
    this.totalAmount = 0.0,
    DateTime? startDate,
    DateTime? endDate,
    this.isIncome = false,
    this.errorMessage = '',
    this.selectedPeriod = DatePeriod.month,
  }) : startDate = startDate ?? _getDefaultStartDate(),
       endDate = endDate ?? _getDefaultEndDate();

  static DateTime _getDefaultStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime _getDefaultEndDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
  }

  HistoryState copyWith({
    HistoryStatus? status,
    List<TransactionResponce>? transactions,
    double? totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
    String? errorMessage,
    DatePeriod? selectedPeriod,
  }) {
    return HistoryState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIncome: isIncome ?? this.isIncome,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  String get formattedTotalAmount {
    final formatter = NumberFormat('#,##0');
    return '${formatter.format(totalAmount.round())} ₽';
  }

  String get formattedStartDate {
    switch (selectedPeriod) {
      case DatePeriod.day:
        return DateFormat('dd MMMM yyyy', 'ru_RU').format(startDate);
      case DatePeriod.week:
        return DateFormat('dd.MM.yyyy', 'ru_RU').format(startDate);
      case DatePeriod.month:
        const months = [
          'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
          'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
        ];
        return '${months[startDate.month - 1]} ${startDate.year}';
      case DatePeriod.year:
        return '${startDate.year}';
      case DatePeriod.custom:
        return DateFormat('dd.MM.yyyy', 'ru_RU').format(startDate);
    }
  }

  String get formattedEndDate {
    switch (selectedPeriod) {
      case DatePeriod.day:
        return DateFormat('HH:mm', 'ru_RU').format(endDate);
      case DatePeriod.week:
        return DateFormat('dd.MM.yyyy', 'ru_RU').format(endDate);
      case DatePeriod.month:
        const months = [
          'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
          'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
        ];
        return '${months[endDate.month - 1]} ${endDate.year}';
      case DatePeriod.year:
        return '${endDate.year}';
      case DatePeriod.custom:
        return DateFormat('dd.MM.yyyy', 'ru_RU').format(endDate);
    }
  }

  String get periodDisplayName {
    switch (selectedPeriod) {
      case DatePeriod.day:
        return 'День';
      case DatePeriod.week:
        return 'Неделя';
      case DatePeriod.month:
        return 'Месяц';
      case DatePeriod.year:
        return 'Год';
      case DatePeriod.custom:
        return 'Произвольный';
    }
  }

  bool get isLoading => status == HistoryStatus.loading;
  bool get isSuccess => status == HistoryStatus.success;
  bool get isFailure => status == HistoryStatus.failure;
  bool get isEmpty => transactions.isEmpty && isSuccess;

  @override
  List<Object?> get props => [
        status,
        transactions,
        totalAmount,
        startDate,
        endDate,
        isIncome,
        errorMessage,
        selectedPeriod,
      ];
}