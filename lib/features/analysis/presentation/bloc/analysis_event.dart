import 'package:equatable/equatable.dart';

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalysisInitialized extends AnalysisEvent {
  final bool isIncome;

  const AnalysisInitialized({required this.isIncome});

  @override
  List<Object?> get props => [isIncome];
}

class AnalysisRefreshed extends AnalysisEvent {
  const AnalysisRefreshed();
}

class AnalysisDateRangeChanged extends AnalysisEvent {
  final DateTime startDate;
  final DateTime endDate;

  const AnalysisDateRangeChanged({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
} 