
part of 'transaction.bloc.dart';

abstract class TransactionEvent {
  const TransactionEvent();
}
class LoadTodayTransactions extends TransactionEvent {
  final bool isIncome;

  LoadTodayTransactions({required this.isIncome});
}

