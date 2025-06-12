import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Экран расходов'),
    );
  }
}
