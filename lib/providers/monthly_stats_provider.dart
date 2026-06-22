import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/task_log.dart';
import '../database/database_helper.dart';

class MonthlyStatsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, Map<String, dynamic>> _dailyStats = {};
  DateTime _selectedMonth = DateTime.now();

  Map<String, Map<String, dynamic>> get dailyStats => _dailyStats;
  DateTime get selectedMonth => _selectedMonth;

  Future<void> loadMonthlyStats(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month);
    _dailyStats = {};

    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final tasks = await _dbHelper.getTasksByDate(dateStr);

      int studyMinutes = 0;
      int questionsCount = 0;
      int wasteTimeMinutes = 0;

      for (final task in tasks) {
        final t = Task.fromMap(task);
        final logs = await _dbHelper.getTaskLogsByTaskId(t.id);

        if (t.type == TaskType.study && logs.isNotEmpty) {
          for (final log in logs) {
            final taskLog = TaskLog.fromMap(log);
            studyMinutes += taskLog.actualDurationMinutes;
          }
        } else if (t.type == TaskType.questions && logs.isNotEmpty) {
          for (final log in logs) {
            final taskLog = TaskLog.fromMap(log);
            questionsCount += (taskLog.questionsAttempted ?? 0);
          }
        } else if (t.type == TaskType.wasteTime && logs.isNotEmpty) {
          for (final log in logs) {
            final taskLog = TaskLog.fromMap(log);
            wasteTimeMinutes += taskLog.actualDurationMinutes;
          }
        }
      }

      _dailyStats[dateStr] = {
        'study_hours': (studyMinutes / 60).toStringAsFixed(1),
        'questions': questionsCount,
        'waste_time_hours': (wasteTimeMinutes / 60).toStringAsFixed(1),
        'date': date,
        'study_minutes': studyMinutes,
      };
    }

    notifyListeners();
  }

  void goToPreviousMonth() async {
    final previousMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    await loadMonthlyStats(previousMonth);
  }

  void goToNextMonth() async {
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    await loadMonthlyStats(nextMonth);
  }

  void goToCurrentMonth() async {
    await loadMonthlyStats(DateTime.now());
  }

  double getMonthlyTotalStudy() {
    double total = 0;
    for (final stats in _dailyStats.values) {
      total += double.parse(stats['study_hours'].toString());
    }
    return total;
  }

  int getMonthlyTotalQuestions() {
    int total = 0;
    for (final stats in _dailyStats.values) {
      total += (stats['questions'] as int);
    }
    return total;
  }

  double getMonthlyTotalWasteTime() {
    double total = 0;
    for (final stats in _dailyStats.values) {
      total += double.parse(stats['waste_time_hours'].toString());
    }
    return total;
  }

  double getMonthlyAverageDailyStudy() {
    final total = getMonthlyTotalStudy();
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return total / daysInMonth;
  }

  String getBestDay() {
    double maxStudy = 0;
    String bestDayStr = '';

    _dailyStats.forEach((dateStr, stats) {
      final studyHours = double.parse(stats['study_hours'].toString());
      if (studyHours > maxStudy) {
        maxStudy = studyHours;
        bestDayStr = dateStr;
      }
    });

    if (bestDayStr.isEmpty) return 'N/A';
    final date = DateTime.parse(bestDayStr);
    return '${date.day} (${maxStudy.toStringAsFixed(1)}h)';
  }
}
