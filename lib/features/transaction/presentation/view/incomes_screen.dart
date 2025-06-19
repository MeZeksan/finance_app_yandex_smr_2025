import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Экран доходов'),
    );
  }
}
