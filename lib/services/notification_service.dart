import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    tz.initializeTimeZones();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Request exact alarm permission for Android 13+ (if needed)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> scheduleTodoNotification(Todo todo) async {
    if (todo.reminderDateTime == null) return;

    final scheduleTime = tz.TZDateTime.from(todo.reminderDateTime!, tz.local);
    
    // If it's a non-daily task and the time is in the past, don't schedule
    if (!todo.isDaily && scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final id = todo.id.hashCode;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Reminder: ${todo.title}',
      todo.isDaily ? 'Your daily task is ready!' : 'It\'s time for your task!',
      todo.isDaily 
          ? _nextInstanceOfTime(todo.reminderDateTime!)
          : scheduleTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription: 'Notifications for your todo tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: todo.isDaily ? DateTimeComponents.time : null,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(String todoId) async {
    await flutterLocalNotificationsPlugin.cancel(todoId.hashCode);
  }
}
