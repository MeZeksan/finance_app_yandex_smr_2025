import 'package:flutter/material.dart';

class AnalysisHeader extends StatelessWidget {
  const AnalysisHeader({
    super.key,
    required this.topPadding,
  });

  final double topPadding;

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Анализ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1D1B20),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
} 