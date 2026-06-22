import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/monthly_stats_provider.dart';

class MonthlyGraph extends StatelessWidget {
  final MonthlyStatsProvider provider;
  final int metricIndex; // 0: study, 1: questions, 2: waste time

  const MonthlyGraph({
    Key? key,
    required this.provider,
    required this.metricIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;

    final barGroups = <BarChartGroupData>[];
    double maxY = 10;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        provider.selectedMonth.year,
        provider.selectedMonth.month,
        day,
      );
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final stats = provider.dailyStats[dateStr];

      double value = 0;
      if (stats != null) {
        if (metricIndex == 0) {
          // Study time in hours
          value = double.parse(stats['study_hours'].toString());
        } else if (metricIndex == 1) {
          // Questions attempted
          value = (stats['questions'] as int).toDouble();
        } else {
          // Waste time in hours
          value = double.parse(stats['waste_time_hours'].toString());
        }
      }

      barGroups.add(
        BarChartGroupData(
          x: day - 1,
          barRods: [
            BarChartRodData(
              toY: value,
              color: _getBarColor(metricIndex),
              width: 3,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(3),
              ),
            ),
          ],
        ),
      );

      if (value > maxY) {
        maxY = value;
      }
    }

    // Add some padding to max Y
    maxY = (maxY * 1.2).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: const Color(0xFF1F1B16),
                tooltipRoundedRadius: 8,
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: daysInMonth > 20 ? 5 : 1,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      (value.toInt() + 1).toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY / 5).ceilToDouble(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBarColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF3B82F6); // Study - Blue
      case 1:
        return const Color(0xFFD97706); // Questions - Amber
      case 2:
        return const Color(0xFFEF4444); // Waste time - Red
      default:
        return const Color(0xFFC2651A); // Default - Orange
    }
  }
}
