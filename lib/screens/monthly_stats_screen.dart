import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/monthly_stats_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import '../widgets/monthly_graph.dart';
import '../widgets/consistency_grid.dart';

class MonthlyStatsScreen extends StatefulWidget {
  const MonthlyStatsScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyStatsScreen> createState() => _MonthlyStatsScreenState();
}

class _MonthlyStatsScreenState extends State<MonthlyStatsScreen> {
  late MonthlyStatsProvider _monthlyProvider;
  int _selectedMetric = 0; // 0: study, 1: questions, 2: waste time

  @override
  void initState() {
    super.initState();
    _monthlyProvider = context.read<MonthlyStatsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monthlyProvider.loadMonthlyStats(DateTime.now());
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
      body: Consumer<MonthlyStatsProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMonthHeader(provider),
                _buildMonthlyStats(provider),
                _buildGraphSection(provider),
                _buildConsistencyGrid(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(MonthlyStatsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.goToPreviousMonth,
          ),
          Text(
            TimeUtils.getMonthYear(provider.selectedMonth),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.goToNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(MonthlyStatsProvider provider) {
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
            'Monthly Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Study Time',
            '${provider.getMonthlyTotalStudy().toStringAsFixed(1)} hours',
            AppColors.physicsBlue,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Total Questions',
            '${provider.getMonthlyTotalQuestions()}',
            AppColors.mathsAmber,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Total Waste Time',
            '${provider.getMonthlyTotalWasteTime().toStringAsFixed(1)} hours',
            AppColors.wasteTimeRed,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          _buildStatRow(
            'Average Daily Study',
            '${provider.getMonthlyAverageDailyStudy().toStringAsFixed(1)} hours',
            AppColors.physicsBlue,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Best Day',
            provider.getBestDay(),
            AppColors.accentOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGraphSection(MonthlyStatsProvider provider) {
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
        MonthlyGraph(
          provider: provider,
          metricIndex: _selectedMetric,
        ),
      ],
    );
  }

  Widget _buildConsistencyGrid(MonthlyStatsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'Consistency Tracker',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ConsistencyGrid(provider: provider),
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
