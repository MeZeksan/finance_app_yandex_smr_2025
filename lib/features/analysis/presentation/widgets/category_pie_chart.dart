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
        badgeWidget: _Badge(
          category: category,
          size: 32,
          borderColor: color,
        ),
        badgePositionPercentageOffset: 0.9,
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
            child: PieChart(
              PieChartData(
                sections: _generateSections(categories),
                centerSpaceRadius: 90,
                sectionsSpace: 1,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Handle touch events if needed
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(categories),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLegend(List<CategoryAnalysis> categories) {
    if (categories.isEmpty) {
      return const SizedBox();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: categories.map((category) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(categories.indexOf(category)),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${category.percentage.toStringAsFixed(0)}% ${category.categoryName}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      }).toList(),
    );
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

class _Badge extends StatelessWidget {
  final CategoryAnalysis category;
  final double size;
  final Color borderColor;

  const _Badge({
    required this.category,
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          category.emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class CategoryPieChartTooltip extends StatelessWidget {
  final CategoryAnalysis category;
  
  const CategoryPieChartTooltip({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.categoryName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${category.percentage.toStringAsFixed(2)}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
} 