import 'package:equatable/equatable.dart';
import 'package:finance_app_yandex_smr_2025/features/analysis/data/models/category_analysis.dart';
import 'package:intl/intl.dart';

enum AnalysisStatus { initial, loading, success, failure }

class AnalysisState extends Equatable {
  final AnalysisStatus status;
  final List<CategoryAnalysis> categories;
  final double totalAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isIncome;
  final String errorMessage;

  AnalysisState({
    this.status = AnalysisStatus.initial,
    this.categories = const [],
    this.totalAmount = 0.0,
    DateTime? startDate,
    DateTime? endDate,
    this.isIncome = false,
    this.errorMessage = '',
  }) : startDate = startDate ?? _getDefaultStartDate(),
       endDate = endDate ?? _getDefaultEndDate();

  static DateTime _getDefaultStartDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime _getDefaultEndDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }

  AnalysisState copyWith({
    AnalysisStatus? status,
    List<CategoryAnalysis>? categories,
    double? totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isIncome,
    String? errorMessage,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIncome: isIncome ?? this.isIncome,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get formattedTotalAmount {
    final formatter = NumberFormat('#,##0');
    return '${formatter.format(totalAmount.round())} ₽';
  }

  String get formattedStartDate {
    return DateFormat('MMMM yyyy', 'ru_RU').format(startDate);
  }

  String get formattedEndDate {
    return DateFormat('MMMM yyyy', 'ru_RU').format(endDate);
  }

  bool get isEmpty => categories.isEmpty;
  bool get isLoading => status == AnalysisStatus.loading;
  bool get isFailure => status == AnalysisStatus.failure;
  bool get isSuccess => status == AnalysisStatus.success;

  @override
  List<Object?> get props => [
    status, 
    categories, 
    totalAmount, 
    startDate, 
    endDate, 
    isIncome, 
    errorMessage
  ];
} 