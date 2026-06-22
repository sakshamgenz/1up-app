import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'alarm_service.dart';

// Background task for alarm callback
@pragma('vm:entry-point')
Future<void> alarmCallback(int alarmId, {String? taskId, String? taskName}) async {
  // This is called in a background isolate
  final alarmService = AlarmService();
  await alarmService.initialize();

  // Show notification
  // This is already handled by the scheduler in AlarmService
  print('Alarm triggered for task: $taskName (ID: $alarmId)');
}

class BackgroundAlarmManager {
  static Future<void> scheduleBackgroundAlarm({
    required int alarmId,
    required String taskId,
    required String taskName,
    required DateTime alarmTime,
  }) async {
    final durationUntilAlarm = alarmTime.difference(DateTime.now());

    if (durationUntilAlarm.isNegative) {
      return; // Don't schedule alarms in the past
    }

    // Schedule using Android Alarm Manager for background execution
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      alarmId,
      alarmCallback,
      exact: true,
      allowWhileIdle: true,
      wakeup: true,
      rescheduleOnBoot: true,
    );
  }

  static Future<void> cancelBackgroundAlarm(int alarmId) async {
    await AndroidAlarmManager.cancel(alarmId);
  }
}
