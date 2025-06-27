import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountView();
  }
}

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = statusBarHeight + 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFb2AE881),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Мой счет',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        // TODO: Implement edit functionality
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              children: [
                // Balance Container
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4FAE6),
                  ),
                  child: Column(
                    children: [
                      // Balance Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text(
                              'Баланс',
                              style: TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '-670 000 ₽',
                              style: const TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF1D1B20),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                      // Currency Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text(
                              'Валюта',
                              style: TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₽',
                              style: const TextStyle(
                                color: Color(0xFF1D1B20),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF1D1B20),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Placeholder for graph
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'График будет добавлен позже',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        heroTag: 'accountButtonTag',
        shape: const CircleBorder(),
        onPressed: () {
          // TODO: Implement add functionality
        },
        backgroundColor: const Color(0xFFb2AE881),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
