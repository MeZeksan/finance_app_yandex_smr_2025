import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/balance_data/balance_data.dart';

class BalanceChart extends StatelessWidget {
  final List<BalanceData> balanceData;
  const BalanceChart({super.key, required this.balanceData});

  @override
  Widget build(BuildContext context) {
    final data = balanceData;
    
    if (data.isEmpty) {
      return Container(
        color: Colors.transparent,
        child: const Center(
          child: Text(
            'Нет данных для отображения',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.center,
          maxY: _getMaxY(data),
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[groupIndex];
                final value = d.amount;
                final formatted = NumberFormat('#,##0').format(value);
                final dateStr = DateFormat('dd.MM').format(d.date);
                final typeStr = d.type == 'income' ? 'Доход' : 'Расход';
                return BarTooltipItem(
                  '$dateStr\n$typeStr\n$formatted ₽',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < data.length) {
                    final d = data[idx];
                    final day = d.date.day;
                    // Показываем только 1, средний день месяца и последний день месяца
                    final now = DateTime.now();
                    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
                    
                    if (day == 1 || day == lastDayOfMonth ~/ 2 || day == lastDayOfMonth) {
                      final dateStr = DateFormat('dd.MM').format(d.date);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final idx = entry.key;
            final d = entry.value;
            final barColor = d.type == 'income' ? const Color(0xFF19E28A) : const Color(0xFFFF6600);
            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: d.amount,
                  color: barColor,
                  width: 6,
                  borderRadius: BorderRadius.all(Radius.circular(92)),
                ),
              ],
              showingTooltipIndicators: [],
            );
          }).toList(),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  double _getMaxY(List<BalanceData> data) {
    if (data.isEmpty) return 100000;
    final maxValue = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }
} 