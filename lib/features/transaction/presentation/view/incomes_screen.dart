import 'package:finance_app_yandex_smr_2025/core/di/service_locator.dart';
import 'package:finance_app_yandex_smr_2025/features/transaction/presentation/view/transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionsScreen(
      repository: ServiceLocator.transactionRepository,
      isIncome: true,
      buttonTag: 'incomesButtonTag',
    );
  }
}
