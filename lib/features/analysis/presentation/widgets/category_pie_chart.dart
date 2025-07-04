import 'dart:math';

import 'package:finance_app_yandex_smr_2025/features/analysis/data/models/category_analysis.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryAnalysis> categories;
  final double totalAmount;
  final bool animate;

  const CategoryPieChart({
    super.key,
    required this.categories,
    required this.totalAmount,
    this.animate = false,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  List<CategoryAnalysis>? _oldCategories;
  List<CategoryAnalysis>? _newCategories;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fade out until 180 degrees (0.5 of animation), then fade in until 360 degrees
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
          _oldCategories = null;
        });
      }
    });

    _newCategories = widget.categories;
  }

  @override
  void didUpdateWidget(CategoryPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if the categories have changed and animation is requested
    if (widget.animate && 
        (oldWidget.categories.length != widget.categories.length || 
        !_areListsEqual(oldWidget.categories, widget.categories) || 
        oldWidget.totalAmount != widget.totalAmount)) {
      setState(() {
        _oldCategories = oldWidget.categories;
        _newCategories = widget.categories;
        _isAnimating = true;
      });
      _animationController.reset();
      _animationController.forward();
    } else if (!_isAnimating) {
      _newCategories = widget.categories;
    }
  }
  
  // Helper to compare category lists
  bool _areListsEqual(List<CategoryAnalysis> list1, List<CategoryAnalysis> list2) {
    if (list1.isEmpty && list2.isEmpty) return true;
    if (list1.isEmpty || list2.isEmpty) return false;
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].categoryName != list2[i].categoryName || 
          list1[i].amount != list2[i].amount || 
          list1[i].percentage != list2[i].percentage) {
        return false;
      }
    }
    
    return true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<PieChartSectionData> _generateSections(List<CategoryAnalysis> categories) {
    if (categories.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 30,
          showTitle: false,
        )
      ];
    }

    // Generate a color for each category
    final List<Color> colors = [
      const Color(0xFF66BB6A),  // Green
      const Color(0xFFFFEB3B),  // Yellow
      const Color(0xFFF44336),  // Red
      const Color(0xFF2196F3),  // Blue
      const Color(0xFFFF9800),  // Orange
      const Color(0xFF9C27B0),  // Purple
      const Color(0xFF00BCD4),  // Cyan
      const Color(0xFFE91E63),  // Pink
      const Color(0xFF795548),  // Brown
      const Color(0xFF607D8B),  // Blue Grey
    ];

    return List.generate(categories.length, (i) {
      final category = categories[i];
      final color = colors[i % colors.length];
      
      return PieChartSectionData(
        color: color,
        value: category.percentage,
        title: '',
        radius: 30,
        showTitle: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use old categories for first half of animation, new categories for second half
    final categories = _isAnimating ? 
        (_animationController.value < 0.5 ? _oldCategories! : _newCategories!) : 
        _newCategories!;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: _generateSections(categories),
                    centerSpaceRadius: 100,
                    sectionsSpace: 1,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch events if needed
                      },
                    ),
                  ),
                ),
                // Legend inside the circle
                SizedBox(
                  width: 160,
                  height: 160,
                  child: _buildInnerLegend(categories),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInnerLegend(List<CategoryAnalysis> categories) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((category) {
          final index = categories.indexOf(category);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${category.percentage.toStringAsFixed(0)}% ${category.categoryName}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend(List<CategoryAnalysis> categories) {
    // This method is no longer used, but keeping it for compatibility
    return const SizedBox();
  }

  Color _getCategoryColor(int index) {
    final List<Color> colors = [
      const Color(0xFF66BB6A),  // Green
      const Color(0xFFFFEB3B),  // Yellow
      const Color(0xFFF44336),  // Red
      const Color(0xFF2196F3),  // Blue
      const Color(0xFFFF9800),  // Orange
      const Color(0xFF9C27B0),  // Purple
      const Color(0xFF00BCD4),  // Cyan
      const Color(0xFFE91E63),  // Pink
      const Color(0xFF795548),  // Brown
      const Color(0xFF607D8B),  // Blue Grey
    ];
    return colors[index % colors.length];
  }
} 