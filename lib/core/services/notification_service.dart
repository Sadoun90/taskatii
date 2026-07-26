import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/features/main_layout/main_layout.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:taskatii/core/services/local_storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Reserved notification IDs for focus/pomodoro sessions
  static const int _focusOngoingNotifId = 999997;
  static const int _focusNotifId = 999998;

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
        if (response.payload == 'focus') {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainLayout(initialIndex: 2),
            ),
            (route) => false,
          );
        } else if (response.payload != null && response.payload!.startsWith('task:')) {
          final taskId = response.payload!.replaceFirst('task:', '');
          final task = AppLocalStorage.taskBox.get(taskId);

          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainLayout(
                initialIndex: 0,
                targetTask: task,
              ),
            ),
            (route) => false,
          );
        }
      },
    );

    // Create Notification Channels for Android 8.0+
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();

      const AndroidNotificationChannel reminderChannel =
          AndroidNotificationChannel(
        'taskatii_reminders',
        'Task Reminders',
        description: 'Notifications for upcoming taskatii tasks',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel focusChannel =
          AndroidNotificationChannel(
        'taskatii_focus',
        'Focus Sessions',
        description: 'Pomodoro / focus timer notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel focusOngoingChannel =
          AndroidNotificationChannel(
        'taskatii_focus_ongoing',
        'Active Focus Timer',
        description: 'Ongoing Pomodoro focus countdown timer',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );

      await androidImplementation.createNotificationChannel(reminderChannel);
      await androidImplementation.createNotificationChannel(focusChannel);
      await androidImplementation.createNotificationChannel(focusOngoingChannel);
    }
  }

  // ─────────────────────────────────────────────
  // Task Reminder Notification (Scheduled)
  // ─────────────────────────────────────────────

  static Future<void> scheduleTaskNotification(TaskModel task) async {
    if (task.notificationId == null) return;

    try {
      // Parse task date with multi-format fallback
      DateTime date;
      try {
        date = DateFormat.yMd().parse(task.date);
      } catch (_) {
        try {
          date = DateFormat('M/d/yyyy').parse(task.date);
        } catch (_) {
          try {
            date = DateFormat('d/M/yyyy').parse(task.date);
          } catch (_) {
            date = DateTime.now();
          }
        }
      }

      // Parse task time with multi-format fallback
      DateTime time;
      try {
        time = DateFormat('h:mm a').parse(task.startTime);
      } catch (_) {
        try {
          time = DateFormat('hh:mm a').parse(task.startTime);
        } catch (_) {
          try {
            time = DateFormat('HH:mm').parse(task.startTime);
          } catch (_) {
            time = DateTime.now();
          }
        }
      }

      DateTime scheduledDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Calculate reminder time (6 hours before scheduled task start time)
      DateTime now = DateTime.now();
      DateTime reminderTime = scheduledDate.subtract(const Duration(hours: 6));

      if (reminderTime.isBefore(now)) {
        if (scheduledDate.isAfter(now)) {
          reminderTime = scheduledDate;
        } else {
          // If task starts right now or recently, trigger in 5 seconds
          reminderTime = now.add(const Duration(seconds: 5));
        }
      }

      String remainingText = scheduledDate.isAfter(now)
          ? (scheduledDate.difference(now).inHours >= 1
              ? 'Starts in ${scheduledDate.difference(now).inHours} hours'
              : 'Starts in ${scheduledDate.difference(now).inMinutes} mins')
          : 'Starts Now';

      String titleText = '⏰ TASK ALARM: ${task.title}';
      String bodyText = task.discription.isNotEmpty
          ? '📌 Scheduled: ${task.startTime} - ${task.endTime}\n📝 ${task.discription}'
          : '📌 Scheduled Start: ${task.startTime} | Time to get to work! 🚀';

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        bodyText,
        htmlFormatBigText: true,
        contentTitle: '⏰ <b>${task.title}</b>',
        htmlFormatContentTitle: true,
        summaryText: 'Taskatii Alarm 🕒 $remainingText',
        htmlFormatSummaryText: true,
      );

      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'taskatii_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for upcoming taskatii tasks',
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        styleInformation: bigTextStyleInformation,
        playSound: true,
        enableVibration: true,
        subText: '⏰ $remainingText',
      );

      NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
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

      // Only show immediate status bar notification if task starts within 6 hours
      bool isStartingSoon = scheduledDate.difference(now).inHours <= 6;
      if (isStartingSoon) {
        try {
          await _notificationsPlugin.show(
            task.notificationId!,
            titleText,
            bodyText,
            details,
            payload: 'task:${task.id}',
          );
        } catch (_) {}
      } else {
        // If task is far in future (> 6 hours), cancel any previous status bar card
        await _notificationsPlugin.cancel(task.notificationId!);
      }

      try {
        if (matchDateTimeComponents != null) {
          await _notificationsPlugin.zonedSchedule(
            task.notificationId!,
            titleText,
            bodyText,
            tzScheduledTime,
            details,
            payload: 'task:${task.id}',
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
            payload: 'task:${task.id}',
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      } catch (_) {
        // Fallback for Android OS restricting exact alarms without special permission
        await _notificationsPlugin.zonedSchedule(
          task.notificationId!,
          titleText,
          bodyText,
          tzScheduledTime,
          details,
          payload: 'task:${task.id}',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (_) {}
  }

  static Future<void> cancelNotification(int? notificationId) async {
    if (notificationId != null) {
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  // ─────────────────────────────────────────────
  // Focus / Pomodoro Live Countdown Notifications
  // ─────────────────────────────────────────────

  /// Starts ongoing chronometer notification & schedules completion alert.
  static Future<void> scheduleFocusEndNotification({
    required int durationSeconds,
    String? taskTitle,
  }) async {
    await cancelFocusNotification();

    final DateTime endTime =
        DateTime.now().add(Duration(seconds: durationSeconds));
    final tz.TZDateTime tzEndTime = tz.TZDateTime.from(endTime, tz.local);
    final String endTimeString = DateFormat('hh:mm a').format(endTime);

    final String ongoingTitle = taskTitle != null && taskTitle.isNotEmpty
        ? '⏱️ FOCUS: $taskTitle (FINISH: $endTimeString)'
        : '⏱️ FOCUS SESSION ACTIVE (FINISH: $endTimeString)';

    final String ongoingBody =
        '🎯 TASK: ${taskTitle ?? "Focus Session"}\n⏰ END TIME: $endTimeString\n⏳ COUNTDOWN ACTIVE IN STATUS BAR';

    final BigTextStyleInformation bigTextStyleOngoing = BigTextStyleInformation(
      ongoingBody,
      htmlFormatBigText: true,
      contentTitle: '⏱️ <b>$ongoingTitle</b>',
      htmlFormatContentTitle: true,
      summaryText: '⌛ Ends at $endTimeString',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails ongoingAndroidDetails =
        AndroidNotificationDetails(
      'taskatii_focus_ongoing',
      'Active Focus Timer',
      channelDescription: 'Ongoing Pomodoro focus countdown timer',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigTextStyleOngoing,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      usesChronometer: true,
      chronometerCountDown: true,
      when: endTime.millisecondsSinceEpoch,
      showWhen: true,
      subText: '⌛ Ends: $endTimeString',
    );

    final NotificationDetails ongoingDetails = NotificationDetails(
      android: ongoingAndroidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
      ),
    );

    try {
      await _notificationsPlugin.show(
        _focusOngoingNotifId,
        ongoingTitle,
        ongoingBody,
        ongoingDetails,
        payload: 'focus',
      );
    } catch (_) {}

    // 2. Scheduled completion notification when time reaches 0
    final String title = '🎉 FOCUS SESSION COMPLETED!';
    final String body = taskTitle != null && taskTitle.isNotEmpty
        ? 'Great work on "$taskTitle"!\nTime for a well-deserved 5-minute break. 🧘'
        : 'Amazing focus!\nTime to take a 5-minute break. 🧘';

    final BigTextStyleInformation bigTextStyleComplete = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: '<b>$title</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Taskatii Focus Complete 🏆',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails completeAndroidDetails =
        AndroidNotificationDetails(
      'taskatii_focus',
      'Focus Sessions',
      channelDescription: 'Pomodoro / focus timer notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      styleInformation: bigTextStyleComplete,
      playSound: true,
      enableVibration: true,
    );

    final NotificationDetails completeDetails = NotificationDetails(
      android: completeAndroidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        _focusNotifId,
        title,
        body,
        tzEndTime,
        completeDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      try {
        await _notificationsPlugin.zonedSchedule(
          _focusNotifId,
          title,
          body,
          tzEndTime,
          completeDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  /// Shows immediate completion notification when the timer finishes.
  static Future<void> showFocusCompleteNotification({
    String? taskTitle,
  }) async {
    await cancelFocusNotification();

    final String title = '🎉 FOCUS SESSION COMPLETED!';
    final String body = taskTitle != null && taskTitle.isNotEmpty
        ? 'Great work on "$taskTitle"!\nTime for a 5-minute break. 🧘'
        : 'Amazing focus!\nTime to take a 5-minute break. 🧘';

    final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: '<b>$title</b>',
      htmlFormatContentTitle: true,
      summaryText: 'Focus Session Finished 🏆',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'taskatii_focus',
      'Focus Sessions',
      channelDescription: 'Pomodoro / focus timer notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      styleInformation: bigTextStyle,
      playSound: true,
      enableVibration: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.show(
        _focusNotifId,
        title,
        body,
        details,
      );
    } catch (_) {}
  }

  /// Cancels all focus session notifications (ongoing & completion).
  static Future<void> cancelFocusNotification() async {
    await _notificationsPlugin.cancel(_focusOngoingNotifId);
    await _notificationsPlugin.cancel(_focusNotifId);
  }
}
