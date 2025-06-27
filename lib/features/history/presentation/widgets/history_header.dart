import 'package:finance_app_yandex_smr_2025/features/analysis/presentation/view/analysis_screen.dart';
import 'package:finance_app_yandex_smr_2025/features/history/presentation/bloc/history_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({
    super.key,
    required this.topPadding,
  });

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HistoryBloc>().state;
    
    return Container(
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
            Positioned(
              left: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1D1B20),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              'Моя история',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1D1B20),
              ),
            ),
            Positioned(
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AnalysisScreen(
                          isIncome: state.isIncome,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Color(0xFF1D1B20),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
