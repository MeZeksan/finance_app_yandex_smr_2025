part of 'transaction.bloc.dart';
abstract class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState{}
class TransactionLoading extends TransactionState{}
class TransactionLoaded extends TransactionState {
  final List<TransactionResponce> transactions;
  final String totalAmount;

  const TransactionLoaded({
    required this.transactions,
    required this.totalAmount,
  });
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});
}