import 'package:finance_app_yandex_smr_2025/features/transaction/data/models/transaction/transaction_responce/transaction_responce.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transaction_event.bloc.dart';
part 'transaction_state.bloc.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<TransactionEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}