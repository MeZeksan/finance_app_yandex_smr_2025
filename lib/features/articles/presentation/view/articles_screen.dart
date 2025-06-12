import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Экран статей'),
    );
  }
}
