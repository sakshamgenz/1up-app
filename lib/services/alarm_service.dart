import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:async';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  static const String channelId = 'jee_planner_alarms';
  static const String channelName = 'JEE Planner Alarms';
  static const String channelDescription = 'Notifications for JEE Planner tasks';

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  factory AlarmService() {
    return _instance;
  }

  AlarmService._internal();

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSInitSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize Android Alarm Manager
    await AndroidAlarmManager.initialize();
  }

  Future<void> scheduleAlarm({
    required int alarmId,
    required String taskId,
    required String taskName,
    required DateTime alarmTime,
    required String triggerType, // "5_min_before", "15_min_before", "at_start", "at_deadline"
    required String? soundFile,
  }) async {
    final duration = alarmTime.difference(DateTime.now());

    if (duration.isNegative) {
      return; // Don't schedule alarms in the past
    }

    // Schedule notification
    await _notificationsPlugin.zonedSchedule(
      alarmId,
      'Time for: $taskName',
      _getTriggerMessage(triggerType),
      alarmTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          enableLights: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'notification_sound.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAlarm(int alarmId) async {
    await _notificationsPlugin.cancel(alarmId);
  }

  Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }

  void _handleNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to app with task ID
    // This can be extended to open the specific task
    print('Notification tapped: ${response.payload}');
  }

  String _getTriggerMessage(String triggerType) {
    switch (triggerType) {
      case '15_min_before':
        return '15 minutes until start';
      case '5_min_before':
        return '5 minutes until start';
      case 'at_start':
        return 'Time to start!';
      case 'at_deadline':
        return 'Deadline reached!';
      default:
        return 'Time to check your task';
    }
  }
}
