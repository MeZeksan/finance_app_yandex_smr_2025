import 'package:auto_route/annotations.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/data/repositoryI/mock_transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/domain/repository/transaction_repository.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/view/transaction_screen.dart';
import 'package:flutter/material.dart';

@RoutePage()
class IncomesScreen extends StatelessWidget {
   final TransactionRepository repository = MockTransactionRepository();

   IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionsScreen(isIncome: true, repository: repository);
  }
}
