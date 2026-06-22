import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';

class DayPlannerProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;

  DayPlannerProvider() {
    loadTasksForDate(_selectedDate);
  }

  Future<void> loadTasksForDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final taskMaps = await _dbHelper.getTasksByDate(dateStr);
    _tasks = taskMaps.map((map) => Task.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadTasksForDate(date);
  }

  Future<void> addTask(Task task) async {
    await _dbHelper.insertTask(task.toMap());
    await loadTasksForDate(_selectedDate);
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task.toMap());
    await loadTasksForDate(_selectedDate);
  }

  Future<void> deleteTask(String taskId) async {
    await _dbHelper.deleteTask(taskId);
    await loadTasksForDate(_selectedDate);
  }

  void goToToday() async {
    await selectDate(DateTime.now());
  }

  void goToPreviousDay() async {
    await selectDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void goToNextDay() async {
    await selectDate(_selectedDate.add(const Duration(days: 1)));
  }
}
