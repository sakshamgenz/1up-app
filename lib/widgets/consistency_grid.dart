import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/monthly_stats_provider.dart';
import '../theme/app_theme.dart';

class ConsistencyGrid extends StatelessWidget {
  final MonthlyStatsProvider provider;

  const ConsistencyGrid({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final firstDayOfMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday - 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dayLabels
                .map(
                  (label) => SizedBox(
                    width: 45,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Grid of days
          ..._buildWeeks(daysInMonth, firstWeekday, provider),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('0h', AppColors.background),
              _buildLegendItem('1-4h', AppColors.accentOrange.withOpacity(0.3)),
              _buildLegendItem('4-8h', AppColors.accentOrange.withOpacity(0.6)),
              _buildLegendItem('8+h', AppColors.accentOrange),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(
    int daysInMonth,
    int firstWeekday,
    MonthlyStatsProvider provider,
  ) {
    final weeks = <Widget>[];
    int dayCounter = 1;

    while (dayCounter <= daysInMonth) {
      final week = <Widget>[];

      // Add empty cells for days before the month starts
      if (weeks.isEmpty) {
        for (int i = 0; i < firstWeekday; i++) {
          week.add(
            SizedBox(
              width: 45,
              height: 45,
              child: Container(),
            ),
          );
        }
      }

      // Add day cells
      while (week.length < 7 && dayCounter <= daysInMonth) {
        final date = DateTime(
          provider.selectedMonth.year,
          provider.selectedMonth.month,
          dayCounter,
        );
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final stats = provider.dailyStats[dateStr];

        final studyMinutes = (stats?['study_minutes'] as int?) ?? 0;
        final studyHours = studyMinutes / 60;

        week.add(_buildDayCell(dayCounter, studyHours));
        dayCounter++;
      }

      // Add empty cells to complete the week
      while (week.length < 7) {
        week.add(
          SizedBox(
            width: 45,
            height: 45,
            child: Container(),
          ),
        );
      }

      weeks.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: week,
        ),
      );
      weeks.add(const SizedBox(height: 8));
    }

    return weeks;
  }

  Widget _buildDayCell(int day, double studyHours) {
    Color cellColor;

    if (studyHours >= 8) {
      cellColor = AppColors.accentOrange;
    } else if (studyHours >= 4) {
      cellColor = AppColors.accentOrange.withOpacity(0.6);
    } else if (studyHours >= 1) {
      cellColor = AppColors.accentOrange.withOpacity(0.3);
    } else {
      cellColor = AppColors.background;
    }

    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
