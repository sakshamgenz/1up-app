import 'package:uuid/uuid.dart';
import 'task.dart';

class TaskLog {
  final String id;
  final String taskId;
  final String date; // YYYY-MM-DD format
  final int? lecturesCompleted;
  final int actualDurationMinutes;
  final Difficulty? difficulty;
  final int? questionsAttempted;
  final Subject? subject;
  final String? notes;
  final DateTime completedAt;

  TaskLog({
    String? id,
    required this.taskId,
    required this.date,
    this.lecturesCompleted,
    required this.actualDurationMinutes,
    this.difficulty,
    this.questionsAttempted,
    this.subject,
    this.notes,
    DateTime? completedAt,
  })
  : id = id ?? const Uuid().v4(),
    completedAt = completedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'date': date,
      'lectures_completed': lecturesCompleted,
      'actual_duration_minutes': actualDurationMinutes,
      'difficulty': difficulty?.index,
      'questions_attempted': questionsAttempted,
      'subject': subject?.index,
      'notes': notes,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory TaskLog.fromMap(Map<String, dynamic> map) {
    return TaskLog(
      id: map['id'],
      taskId: map['task_id'],
      date: map['date'],
      lecturesCompleted: map['lectures_completed'],
      actualDurationMinutes: map['actual_duration_minutes'],
      difficulty: map['difficulty'] != null ? Difficulty.values[map['difficulty']] : null,
      questionsAttempted: map['questions_attempted'],
      subject: map['subject'] != null ? Subject.values[map['subject']] : null,
      notes: map['notes'],
      completedAt: DateTime.parse(map['completed_at']),
    );
  }
}
