import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

  // Reserved notification IDs & Channel IDs
  static const String _alarmChannelId = 'taskatii_reminders';
  static const String _focusChannelId = 'taskatii_focus';
  static const String _focusOngoingChannelId = 'taskatii_focus_live_v100';

  static const int _focusOngoingNotifId = 888881;
  static const int _focusNotifId = 888882;

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error initializing local timezone: $e');
    }

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
        handleNotificationPayload(response.payload);
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
        _alarmChannelId,
        'Task Alarms',
        description: 'Loud alarm notifications for taskatii tasks',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      const AndroidNotificationChannel focusChannel =
          AndroidNotificationChannel(
        _focusChannelId,
        'Focus Sessions',
        description: 'Pomodoro / focus timer notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel focusOngoingChannel =
          AndroidNotificationChannel(
        _focusOngoingChannelId,
        'Active Focus Timer',
        description: 'Ongoing Pomodoro focus countdown timer',
        importance: Importance.max,
        playSound: false,
        enableVibration: false,
      );

      await androidImplementation.createNotificationChannel(reminderChannel);
      await androidImplementation.createNotificationChannel(focusChannel);
      await androidImplementation.createNotificationChannel(focusOngoingChannel);
    }
  }

  // ─────────────────────────────────────────────
  // Helper Date/Time Parser
  // ─────────────────────────────────────────────

  static DateTime? parseTaskDateTime(String dateStr, String timeStr) {
    DateTime? parsedDate;
    final dateFormats = [
      DateFormat.yMd(),
      DateFormat('M/d/yyyy'),
      DateFormat('d/M/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('yyyy/MM/dd'),
    ];
    for (final fmt in dateFormats) {
      try {
        parsedDate = fmt.parse(dateStr);
        break;
      } catch (_) {}
    }
    if (parsedDate == null) return null;

    DateTime? parsedTime;
    final timeFormats = [
      DateFormat('h:mm a'),
      DateFormat('hh:mm a'),
      DateFormat('H:mm'),
      DateFormat('HH:mm'),
    ];
    for (final fmt in timeFormats) {
      try {
        parsedTime = fmt.parse(timeStr);
        break;
      } catch (_) {}
    }
    if (parsedTime == null) return null;

    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  // ─────────────────────────────────────────────
  // Overdue Task Notifications
  // ─────────────────────────────────────────────

  /// Checks for tasks that are overdue and shows a notification for each missed task.
  static Future<void> checkAndNotifyOverdueTasks() async {
    try {
      final now = DateTime.now();
      final tasks = AppLocalStorage.taskBox.values;

      for (final task in tasks) {
        if (task.isCompleted) continue;
        if (task.isRepeat != null &&
            task.isRepeat!.isNotEmpty &&
            task.isRepeat != 'None') continue;

        // Ensure each missed task notification is only displayed ONCE
        bool alreadyNotified =
            AppLocalStorage.getCachedData('overdue_notified_${task.id}') ?? false;
        if (alreadyNotified) continue;

        final scheduledDate = parseTaskDateTime(task.date, task.startTime);
        if (scheduledDate == null) continue;

        DateTime? endDate = parseTaskDateTime(task.date, task.endTime);
        DateTime thresholdDate = (endDate != null && endDate.isAfter(scheduledDate))
            ? endDate
            : scheduledDate.add(const Duration(minutes: 2));

        // If task threshold time has passed (overdue) within the last 48 hours
        final diffInMinutes = now.difference(thresholdDate).inMinutes;
        if (thresholdDate.isBefore(now) && diffInMinutes >= 0 && diffInMinutes <= 2880) {
          final int overdueId =
              ((task.notificationId ?? task.id.hashCode.abs()) % 400000) + 500000;

          final body = '⚠️ You missed: "${task.title}" scheduled at ${task.startTime}';

          final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: '<b>⚠️ Overdue Task!</b>',
            htmlFormatContentTitle: true,
            summaryText: 'Taskatii Missed Task',
          );

          final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
            _alarmChannelId,
            'Task Reminders',
            channelDescription: 'Loud alarm notifications for taskatii tasks',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            styleInformation: bigTextStyle,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          );

          final details = NotificationDetails(
            android: androidDetails,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          );

          await _notificationsPlugin.show(
            overdueId,
            '⚠️ Overdue Task!',
            body,
            details,
            payload: 'task:${task.id}',
          );

          // Record flag so this notification never repeats on app relaunch
          AppLocalStorage.casheData('overdue_notified_${task.id}', true);
        }
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // Task Reminder Notifications (Start & Overdue)
  // ─────────────────────────────────────────────

  static Future<void> scheduleTaskNotification(TaskModel task) async {
    if (task.notificationId == null) return;

    try {
      DateTime now = DateTime.now();

      // 1. Parse Start Date & Time
      DateTime date = parseTaskDateTime(task.date, task.startTime) ?? now;
      DateTime scheduledStart = DateTime(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
      );

      // 2. Parse End Date & Time (Fallback: Start + 1 hour)
      DateTime? endDateParsed = parseTaskDateTime(task.date, task.endTime);
      DateTime scheduledEnd = (endDateParsed != null && endDateParsed.isAfter(scheduledStart))
          ? endDateParsed
          : scheduledStart.add(const Duration(hours: 1));

      final int startNotifId = task.notificationId!;
      final int overdueNotifId = ((startNotifId % 400000) + 500000);

      // 3. Schedule START Alarm Notification (fires at task.startTime)
      if (scheduledStart.isAfter(now)) {
        String remainingText = scheduledStart.difference(now).inHours >= 1
            ? 'Starts in ${scheduledStart.difference(now).inHours} hours'
            : 'Starts in ${scheduledStart.difference(now).inMinutes} mins';

        String startTitle = '⏰ TASK ALARM: ${task.title}';
        String startBody = task.discription.isNotEmpty
            ? '📌 Scheduled: ${task.startTime} - ${task.endTime}\n📝 ${task.discription}'
            : '📌 Scheduled Start: ${task.startTime} | Time to get to work! 🚀';

        BigTextStyleInformation bigTextStyleStart = BigTextStyleInformation(
          startBody,
          htmlFormatBigText: true,
          contentTitle: '⏰ <b>${task.title}</b>',
          htmlFormatContentTitle: true,
          summaryText: 'Taskatii Alarm 🕒 $remainingText',
          htmlFormatSummaryText: true,
        );

        AndroidNotificationDetails startAndroidDetails = AndroidNotificationDetails(
          _alarmChannelId,
          'Task Alarms',
          channelDescription: 'Loud alarm notifications for taskatii tasks',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
          styleInformation: bigTextStyleStart,
          playSound: true,
          enableVibration: true,
          subText: '⏰ $remainingText',
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
        );

        NotificationDetails startDetails = NotificationDetails(
          android: startAndroidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        );

        tz.TZDateTime tzStartTime = tz.TZDateTime.from(scheduledStart, tz.local);

        try {
          await _notificationsPlugin.zonedSchedule(
            startNotifId,
            startTitle,
            startBody,
            tzStartTime,
            startDetails,
            payload: 'task:${task.id}',
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {
          await _notificationsPlugin.zonedSchedule(
            startNotifId,
            startTitle,
            startBody,
            tzStartTime,
            startDetails,
            payload: 'task:${task.id}',
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }

      // 4. Schedule OVERDUE Notification (fires automatically at task.endTime)
      if (scheduledEnd.isAfter(now) && !task.isCompleted) {
        String overdueTitle = '⚠️ OVERDUE TASK: ${task.title}';
        String overdueBody =
            '📌 Scheduled end time (${task.endTime}) has passed!\nTap to complete or reschedule.';

        BigTextStyleInformation bigTextStyleOverdue = BigTextStyleInformation(
          overdueBody,
          htmlFormatBigText: true,
          contentTitle: '<b>⚠️ Overdue Task!</b>',
          htmlFormatContentTitle: true,
          summaryText: 'Taskatii Missed Task',
          htmlFormatSummaryText: true,
        );

        AndroidNotificationDetails overdueAndroidDetails = AndroidNotificationDetails(
          _alarmChannelId,
          'Task Reminders',
          channelDescription: 'Loud alarm notifications for taskatii tasks',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          styleInformation: bigTextStyleOverdue,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        );

        NotificationDetails overdueDetails = NotificationDetails(
          android: overdueAndroidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        );

        tz.TZDateTime tzEndTime = tz.TZDateTime.from(scheduledEnd, tz.local);

        try {
          await _notificationsPlugin.zonedSchedule(
            overdueNotifId,
            overdueTitle,
            overdueBody,
            tzEndTime,
            overdueDetails,
            payload: 'task:${task.id}',
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {
          try {
            await _notificationsPlugin.zonedSchedule(
              overdueNotifId,
              overdueTitle,
              overdueBody,
              tzEndTime,
              overdueDetails,
              payload: 'task:${task.id}',
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  static Future<void> cancelNotification(int? notificationId) async {
    if (notificationId != null) {
      final int overdueId = ((notificationId % 400000) + 500000);
      await _notificationsPlugin.cancel(notificationId);
      await _notificationsPlugin.cancel(overdueId);
    }
  }

  static Future<void> requestNotificationPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (_) {}
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

    final String ongoingTitle = (taskTitle != null && taskTitle.trim().isNotEmpty)
        ? '⏱️ FOCUS: $taskTitle'
        : '⏱️ FOCUS SESSION ACTIVE';

    final String ongoingBody = (taskTitle != null && taskTitle.trim().isNotEmpty)
        ? '🎯 Task: $taskTitle | Ends at $endTimeString'
        : '🎯 Focus Session Active | Ends at $endTimeString';

    final AndroidNotificationDetails ongoingAndroidDetails =
        AndroidNotificationDetails(
      _focusOngoingChannelId,
      'Active Focus Timer',
      channelDescription: 'Ongoing Pomodoro focus countdown timer',
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      usesChronometer: true,
      chronometerCountDown: true,
      when: endTime.millisecondsSinceEpoch,
      showWhen: true,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      subText: '⌛ Ends: $endTimeString',
      visibility: NotificationVisibility.public,
    );

    final NotificationDetails ongoingDetails = NotificationDetails(
      android: ongoingAndroidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
      ),
    );

    // 1. Show live ongoing notification in status bar immediately
    try {
      await _notificationsPlugin.show(
        _focusOngoingNotifId,
        ongoingTitle,
        ongoingBody,
        ongoingDetails,
        payload: 'focus',
      );
    } catch (e) {
      debugPrint('Error showing ongoing focus notification: $e');
    }

    // 2. Schedule completion notification when timer ends
    final String title = '🎉 FOCUS SESSION COMPLETED!';
    final String body = (taskTitle != null && taskTitle.trim().isNotEmpty)
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
      _focusChannelId,
      'Focus Sessions',
      channelDescription: 'Pomodoro / focus timer notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      styleInformation: bigTextStyleComplete,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
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
        payload: 'focus',
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
          payload: 'focus',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('Error scheduling focus completion notification: $e');
      }
    }
  }

  /// Shows immediate completion notification when the timer finishes.
  static Future<void> showFocusCompleteNotification({
    String? taskTitle,
  }) async {
    await cancelFocusNotification();

    final String title = '🎉 FOCUS SESSION COMPLETED!';
    final String body = (taskTitle != null && taskTitle.trim().isNotEmpty)
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
      _focusChannelId,
      'Focus Sessions',
      channelDescription: 'Pomodoro / focus timer notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      styleInformation: bigTextStyle,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
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
        payload: 'focus',
      );
    } catch (e) {
      debugPrint('Error showing focus complete notification: $e');
    }
  }

  /// Cancels all focus session notifications (ongoing & completion).
  static Future<void> cancelFocusNotification() async {
    try {
      await _notificationsPlugin.cancel(_focusOngoingNotifId);
      await _notificationsPlugin.cancel(_focusNotifId);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // Tap & Payload Navigation Handlers
  // ─────────────────────────────────────────────

  static Future<NotificationResponse?> getAppLaunchNotificationDetails() async {
    try {
      final details =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        return details.notificationResponse;
      }
    } catch (_) {}
    return null;
  }

  static void handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    if (payload == 'focus') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainLayout(initialIndex: 2),
        ),
        (route) => false,
      );
    } else if (payload.startsWith('task:')) {
      final taskId = payload.replaceFirst('task:', '');
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
  }
}

