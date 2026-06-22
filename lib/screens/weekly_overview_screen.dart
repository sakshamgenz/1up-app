import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weekly_stats_provider.dart';
import '../providers/day_planner_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import 'weekly_graph.dart';

class WeeklyOverviewScreen extends StatefulWidget {
  const WeeklyOverviewScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyOverviewScreen> createState() => _WeeklyOverviewScreenState();
}

class _WeeklyOverviewScreenState extends State<WeeklyOverviewScreen> {
  late WeeklyStatsProvider _weeklyProvider;
  int _selectedMetric = 0; // 0: study, 1: questions, 2: waste time

  @override
  void initState() {
    super.initState();
    _weeklyProvider = context.read<WeeklyStatsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      _weeklyProvider.loadWeeklyStats(weekStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('27'),
        centerTitle: false,
      ),
      body: Consumer<WeeklyStatsProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildWeekHeader(provider),
                _buildSevenDayCards(provider),
                _buildWeeklyStats(provider),
                _buildGraphSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekHeader(WeeklyStatsProvider provider) {
    final endDate = provider.weekStartDate.add(const Duration(days: 6));
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.goToPreviousWeek,
          ),
          Column(
            children: [
              Text(
                'Week of ${provider.weekStartDate.day} - ${endDate.day}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                TimeUtils.getMonthYear(endDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.goToNextWeek,
          ),
        ],
      ),
    );
  }

  Widget _buildSevenDayCards(WeeklyStatsProvider provider) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: List.generate(7, (index) {
            final date = provider.weekStartDate.add(Duration(days: index));
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final stats = provider.dailyStats[dateStr];
            final isToday = dateStr == today;
            final isFuture = date.isAfter(now) && !isToday;

            return GestureDetector(
              onTap: () {
                context.read<DayPlannerProvider>().selectDate(date);
              },
              child: Container(
                width: 90,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday
                      ? Border.all(color: AppColors.accentOrange, width: 2)
                      : Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      dayNames[index],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isFuture && stats != null) ...[_buildDayIndicator(stats)],
                    if (isFuture)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (!isFuture && stats != null)
                      Column(
                        children: [
                          Text(
                            '${stats['study_hours']}h',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${stats['questions']}q',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDayIndicator(Map<String, dynamic> stats) {
    final studyHours = double.parse(stats['study_hours'].toString());
    final questionsCount = stats['questions'] as int;
    final isProductive = studyHours > 0 || questionsCount > 0;

    Color indicatorColor;
    if (studyHours >= 8) {
      indicatorColor = AppColors.accentOrange;
    } else if (studyHours >= 4) {
      indicatorColor = AppColors.accentOrange.withOpacity(0.6);
    } else if (isProductive) {
      indicatorColor = AppColors.accentOrange.withOpacity(0.3);
    } else {
      indicatorColor = Colors.grey.withOpacity(0.3);
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWeeklyStats(WeeklyStatsProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${provider.getWeeklyTotalStudy().toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.physicsBlue,
                    ),
                  ),
                  const Text(
                    'Study Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${provider.getWeeklyTotalQuestions()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mathsAmber,
                    ),
                  ),
                  const Text(
                    'Questions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${provider.getWeeklyTotalWasteTime().toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.wasteTimeRed,
                    ),
                  ),
                  const Text(
                    'Waste Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphSection(WeeklyStatsProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricToggle(0, 'Study', _selectedMetric == 0),
              _buildMetricToggle(1, 'Questions', _selectedMetric == 1),
              _buildMetricToggle(2, 'Waste Time', _selectedMetric == 2),
            ],
          ),
        ),
        WeeklyGraph(
          provider: provider,
          metricIndex: _selectedMetric,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMetricToggle(int index, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMetric = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentOrange.withOpacity(0.2)
              : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.accentOrange, width: 2)
              : Border.all(color: AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.accentOrange : Colors.grey,
          ),
        ),
      ),
    );
  }
}
