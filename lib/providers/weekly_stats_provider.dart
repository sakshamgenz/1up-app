import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/task_log.dart';
import '../database/database_helper.dart';

class WeeklyStatsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, Map<String, dynamic>> _dailyStats = {};
  DateTime _weekStartDate = DateTime.now();

  Map<String, Map<String, dynamic>> get dailyStats => _dailyStats;
  DateTime get weekStartDate => _weekStartDate;

  Future<void> loadWeeklyStats(DateTime startDate) async {
    _weekStartDate = startDate;
    _dailyStats = {};

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
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
        'productive': studyMinutes + questionsCount > 0,
        'date': date,
      };
    }

    notifyListeners();
  }

  void goToPreviousWeek() async {
    final previousWeek = _weekStartDate.subtract(const Duration(days: 7));
    await loadWeeklyStats(previousWeek);
  }

  void goToNextWeek() async {
    final nextWeek = _weekStartDate.add(const Duration(days: 7));
    await loadWeeklyStats(nextWeek);
  }

  void goToCurrentWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    await loadWeeklyStats(weekStart);
  }

  double getWeeklyTotalStudy() {
    double total = 0;
    for (final stats in _dailyStats.values) {
      total += double.parse(stats['study_hours'].toString());
    }
    return total;
  }

  int getWeeklyTotalQuestions() {
    int total = 0;
    for (final stats in _dailyStats.values) {
      total += (stats['questions'] as int);
    }
    return total;
  }

  double getWeeklyTotalWasteTime() {
    double total = 0;
    for (final stats in _dailyStats.values) {
      total += double.parse(stats['waste_time_hours'].toString());
    }
    return total;
  }
}
