import 'package:uuid/uuid.dart';

enum TaskType { study, questions, break_, sleep, wasteTime }
enum TaskStatus { pending, inProgress, completed, overrun }
enum Difficulty { easy, medium, hard }
enum Subject { physics, chemistry, mathematics, other }
enum AlarmTrigger { fifteenMinutesBefore, fiveMinutesBefore, atStart, atDeadline }

class Task {
  final String id;
  final String date; // YYYY-MM-DD format
  final TaskType type;
  final String name;
  final Subject? subject;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final bool alarmSet;
  final String? alarmSound;
  final AlarmTrigger? alarmTrigger;
  final String? notes;
  TaskStatus status;
  final DateTime createdAt;

  Task({
    String? id,
    required this.date,
    required this.type,
    required this.name,
    this.subject,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.alarmSet = false,
    this.alarmSound,
    this.alarmTrigger,
    this.notes,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
  })
  : id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type.index,
      'name': name,
      'subject': subject?.index,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'alarm_set': alarmSet ? 1 : 0,
      'alarm_sound': alarmSound,
      'alarm_trigger': alarmTrigger?.index,
      'notes': notes,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      date: map['date'],
      type: TaskType.values[map['type']],
      name: map['name'],
      subject: map['subject'] != null ? Subject.values[map['subject']] : null,
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      durationMinutes: map['duration_minutes'],
      alarmSet: map['alarm_set'] == 1,
      alarmSound: map['alarm_sound'],
      alarmTrigger: map['alarm_trigger'] != null ? AlarmTrigger.values[map['alarm_trigger']] : null,
      notes: map['notes'],
      status: TaskStatus.values[map['status']],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
