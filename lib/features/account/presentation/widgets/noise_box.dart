import 'dart:math' as math;
import 'package:flutter/material.dart';

class NoiseBox extends StatefulWidget {
  final double width;
  final double height;

  const NoiseBox({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<NoiseBox> createState() => _NoiseBoxState();
}

class _NoiseBoxState extends State<NoiseBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _noiseColors = [
    const Color(0xFFE8E8E8), 
    const Color(0xFFEAEAEA),
    const Color(0xFFECECEC),
    const Color(0xFFE9E9E9),
  ];
  late List<List<Color>> _noiseMatrix;
  final math.Random _random = math.Random();
  List<List<Color>>? _previousMatrix;
  double _transitionProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),  // Более медленная анимация
    )..addListener(() {
        if (mounted) {
          _transitionProgress = _controller.value;
          if (_controller.value == 0.0) {
            _previousMatrix = _noiseMatrix;
            _generateNoiseMatrix();
          }
          setState(() {});
        }
      });

    _generateNoiseMatrix();
    _previousMatrix = List.from(_noiseMatrix);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateNoiseMatrix() {
    const int columns = 8;  
    const int rows = 3;   
    
    _noiseMatrix = List.generate(
      rows,
      (_) => List.generate(
        columns,
        (_) => _noiseColors[_random.nextInt(_noiseColors.length)],
      ),
    );
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: NoisePainter(
          noiseMatrix: _noiseMatrix,
          previousMatrix: _previousMatrix ?? _noiseMatrix,
          progress: _transitionProgress,
          lerpColor: _lerpColor,
        ),
      ),
    );
  }
}

class NoisePainter extends CustomPainter {
  final List<List<Color>> noiseMatrix;
  final List<List<Color>> previousMatrix;
  final double progress;
  final Color Function(Color, Color, double) lerpColor;

  NoisePainter({
    required this.noiseMatrix,
    required this.previousMatrix,
    required this.progress,
    required this.lerpColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / noiseMatrix[0].length;
    final cellHeight = size.height / noiseMatrix.length;

    for (var i = 0; i < noiseMatrix.length; i++) {
      for (var j = 0; j < noiseMatrix[i].length; j++) {
        final currentColor = noiseMatrix[i][j];
        final previousColor = previousMatrix[i][j];
        final lerpedColor = lerpColor(previousColor, currentColor, progress);
        
        final paint = Paint()..color = lerpedColor;
        canvas.drawRect(
          Rect.fromLTWH(
            j * cellWidth,
            i * cellHeight,
            cellWidth,
            cellHeight,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(NoisePainter oldDelegate) => 
    progress != oldDelegate.progress;
} 