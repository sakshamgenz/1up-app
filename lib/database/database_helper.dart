import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'jee_planner.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        type INTEGER NOT NULL,
        name TEXT NOT NULL,
        subject INTEGER,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        alarm_set INTEGER NOT NULL,
        alarm_sound TEXT,
        alarm_trigger INTEGER,
        notes TEXT,
        status INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE task_logs (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        date TEXT NOT NULL,
        lectures_completed INTEGER,
        actual_duration_minutes INTEGER NOT NULL,
        difficulty INTEGER,
        questions_attempted INTEGER,
        subject INTEGER,
        notes TEXT,
        completed_at TEXT NOT NULL,
        FOREIGN KEY(task_id) REFERENCES tasks(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE day_reviews (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        went_well TEXT,
        didnt_go_well TEXT,
        tomorrow_priority TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Task operations
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasksByDate(String date) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'start_time ASC',
    );
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Task Log operations
  Future<int> insertTaskLog(Map<String, dynamic> log) async {
    final db = await database;
    return await db.insert('task_logs', log);
  }

  Future<List<Map<String, dynamic>>> getTaskLogsByTaskId(String taskId) async {
    final db = await database;
    return await db.query(
      'task_logs',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

  // Day Review operations
  Future<int> insertDayReview(Map<String, dynamic> review) async {
    final db = await database;
    return await db.insert('day_reviews', review, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getDayReviewByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'day_reviews',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Analytics queries
  Future<Map<String, dynamic>> getWeeklyStats(DateTime startDate) async {
    final db = await database;
    final endDate = startDate.add(const Duration(days: 7));
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];

    final studyResult = await db.rawQuery('''
      SELECT SUM(actual_duration_minutes) as total_study_minutes
      FROM task_logs
      WHERE type IN (0, 1) AND date BETWEEN ? AND ?
    ''', [startDateStr, endDateStr]);

    return {
      'total_study_minutes': (studyResult.first['total_study_minutes'] as int?) ?? 0,
    };
  }
}
