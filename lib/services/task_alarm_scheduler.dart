import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import 'alarm_service.dart';
import 'background_alarm_manager.dart';

class TaskAlarmScheduler {
  static final TaskAlarmScheduler _instance = TaskAlarmScheduler._internal();
  static int _alarmIdCounter = 1000; // Start alarm IDs from 1000

  factory TaskAlarmScheduler() {
    return _instance;
  }

  TaskAlarmScheduler._internal();

  Future<void> scheduleTaskAlarm(Task task) async {
    if (!task.alarmSet || task.alarmTrigger == null) {
      return; // No alarm to schedule
    }

    final alarmDateTime = _calculateAlarmDateTime(task);
    final alarmId = _generateAlarmId();

    // Schedule both foreground and background alarms
    final alarmService = AlarmService();
    final triggerTypeStr = _alarmTriggerToString(task.alarmTrigger!);

    await alarmService.scheduleAlarm(
      alarmId: alarmId,
      taskId: task.id,
      taskName: task.name,
      alarmTime: alarmDateTime,
      triggerType: triggerTypeStr,
      soundFile: task.alarmSound,
    );

    // Also schedule background alarm for when app is closed
    await BackgroundAlarmManager.scheduleBackgroundAlarm(
      alarmId: alarmId,
      taskId: task.id,
      taskName: task.name,
      alarmTime: alarmDateTime,
    );
  }

  Future<void> cancelTaskAlarm(Task task) async {
    final alarmId = task.id.hashCode.abs() % 10000;
    final alarmService = AlarmService();
    await alarmService.cancelAlarm(alarmId);
    await BackgroundAlarmManager.cancelBackgroundAlarm(alarmId);
  }

  DateTime _calculateAlarmDateTime(Task task) {
    switch (task.alarmTrigger!) {
      case AlarmTrigger.fifteenMinutesBefore:
        return task.startTime.subtract(const Duration(minutes: 15));
      case AlarmTrigger.fiveMinutesBefore:
        return task.startTime.subtract(const Duration(minutes: 5));
      case AlarmTrigger.atStart:
        return task.startTime;
      case AlarmTrigger.atDeadline:
        return task.endTime;
    }
  }

  String _alarmTriggerToString(AlarmTrigger trigger) {
    switch (trigger) {
      case AlarmTrigger.fifteenMinutesBefore:
        return '15_min_before';
      case AlarmTrigger.fiveMinutesBefore:
        return '5_min_before';
      case AlarmTrigger.atStart:
        return 'at_start';
      case AlarmTrigger.atDeadline:
        return 'at_deadline';
    }
  }

  int _generateAlarmId() {
    return _alarmIdCounter++;
  }
}
