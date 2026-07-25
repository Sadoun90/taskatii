import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if payload is available
      },
    );

    // Request permissions for Android 13+ / iOS
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleTaskNotification(TaskModel task) async {
    if (task.notificationId == null) return;

    try {
      // Parse task date and time
      DateTime date = DateFormat.yMd().parse(task.date);
      DateTime time = DateFormat('hh:mm a').parse(task.startTime);

      DateTime scheduledDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      DateTime reminderTime = scheduledDate.subtract(const Duration(minutes: 3));

      if (reminderTime.isBefore(DateTime.now())) {
        if (scheduledDate.isAfter(DateTime.now())) {
          reminderTime = scheduledDate;
        } else if (task.isRepeat == null || task.isRepeat == 'None') {
          return;
        }
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'taskatii_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for upcoming taskatii tasks',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(reminderTime, tz.local);

      DateTimeComponents? matchDateTimeComponents;
      if (task.isRepeat == 'Daily') {
        matchDateTimeComponents = DateTimeComponents.time;
      } else if (task.isRepeat == 'Weekly') {
        matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
      } else if (task.isRepeat == 'Monthly') {
        matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
      }

      String titleText = '⏰ Starting in 3 mins: ${task.title}';
      String bodyText = task.discription.isNotEmpty
          ? '${task.discription} (Starts at ${task.startTime})'
          : 'Get ready! Your task starts at ${task.startTime}';

      if (matchDateTimeComponents != null) {
        await _notificationsPlugin.zonedSchedule(
          task.notificationId!,
          titleText,
          bodyText,
          tzScheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      } else {
        await _notificationsPlugin.zonedSchedule(
          task.notificationId!,
          titleText,
          bodyText,
          tzScheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      // Catch formatting or date parsing exceptions gracefully
    }
  }

  static Future<void> cancelNotification(int? notificationId) async {
    if (notificationId != null) {
      await _notificationsPlugin.cancel(notificationId);
    }
  }
}
