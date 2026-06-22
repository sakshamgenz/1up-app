# Android Alarm Manager Setup

## Required Permissions
The following permissions are required in AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

## Permission Handling at Runtime
For Android 12+ (API 31+), the following permissions require runtime requests:
- `SCHEDULE_EXACT_ALARM` (Android 12+)
- `POST_NOTIFICATIONS` (Android 13+)

## Implementation
1. AlarmService handles scheduling notifications
2. BackgroundAlarmManager handles background execution via AndroidAlarmManager
3. TaskAlarmScheduler orchestrates both
4. Alarms persist across app restarts via rescheduleOnBoot flag

## Testing
- Use Android Emulator with API 33 to test exact alarm permissions
- Test app termination/restart scenarios
- Verify notification appears even when app is closed
