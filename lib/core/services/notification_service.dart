import 'dart:typed_data';
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
  // NOTE: bump the suffix (v2, v3 …) whenever you need to force Android
  // to recreate the channel with new settings (e.g., sound change).
  static const String _alarmChannelId        = 'taskatii_alarm_v2';
  static const String _reminderChannelId     = 'taskatii_reminder_v2';
  static const String _focusChannelId        = 'taskatii_focus';
  static const String _focusOngoingChannelId = 'taskatii_focus_live_v100';

  // Old channel IDs — kept only so we can delete them on first run
  static const List<String> _legacyChannelIds = [
    'taskatii_reminders',
    'taskatii_alarm_v1',
    'taskatii_reminder_v1',
  ];

  static const int _focusOngoingNotifId = 888881;
  static const int _focusNotifId = 888882;

  // Notification ID offsets for each task:
  //   startNotifId        → _getBaseId(notificationId)      (fires at start time: 1 .. 600,000)
  //   overdueNotifId      → _getBaseId(notificationId) + 1M (fires at end time:   1,000,001 .. 1,600,000)
  //   reminderNotifId     → _getBaseId(notificationId) + 2M (fires 6h before:    2,000,001 .. 2,600,000)
  static const int _overdueOffset  = 1000000;
  static const int _reminderOffset = 2000000;

  static int _getBaseId(int notificationId) {
    return (notificationId.abs() % 600000) + 1;
  }

  /// How many hours before the task to send the advance reminder.
  static const int _reminderHoursBefore = 6;

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

      // Delete legacy channels so Android re-creates them with fresh settings
      for (final oldId in _legacyChannelIds) {
        try {
          await androidImplementation.deleteNotificationChannel(oldId);
        } catch (_) {}
      }

      // ── Alarm channel (max importance, alarm audio stream) ──────────────
      // Uses Android's built-in alarm sound via the alarm audio-attributes
      // stream, which also bypasses Do-Not-Disturb.
      final AndroidNotificationChannel alarmChannel =
          AndroidNotificationChannel(
        _alarmChannelId,
        'Task Alarms',
        description: 'Full-volume alarm for task start & overdue alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        showBadge: true,
      );

      // ── Reminder channel (high importance, notification stream) ─────────
      // Used for the 6-hour advance reminder (quieter than the alarm).
      const AndroidNotificationChannel reminderChannel =
          AndroidNotificationChannel(
        _reminderChannelId,
        'Task Reminders',
        description: '6-hour advance reminder for upcoming tasks',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // ── Focus channel ───────────────────────────────────────────────────
      const AndroidNotificationChannel focusChannel =
          AndroidNotificationChannel(
        _focusChannelId,
        'Focus Sessions',
        description: 'Pomodoro / focus timer notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      // ── Focus ongoing (silent countdown) ───────────────────────────────
      const AndroidNotificationChannel focusOngoingChannel =
          AndroidNotificationChannel(
        _focusOngoingChannelId,
        'Active Focus Timer',
        description: 'Ongoing Pomodoro focus countdown timer',
        importance: Importance.max,
        playSound: false,
        enableVibration: false,
      );

      await androidImplementation.createNotificationChannel(alarmChannel);
      await androidImplementation.createNotificationChannel(reminderChannel);
      await androidImplementation.createNotificationChannel(focusChannel);
      await androidImplementation.createNotificationChannel(focusOngoingChannel);
    }
  }

  // ─────────────────────────────────────────────
  // Helper Date/Time Parser
  // ─────────────────────────────────────────────

  static String _normalizeArabicString(String input) {
    String s = input;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(arabicDigits[i], '$i');
    }
    s = s.replaceAll('ص', 'AM').replaceAll('م', 'PM');
    return s.trim();
  }

  static DateTime? parseTaskDateTime(String dateStr, String timeStr) {
    final cleanDateStr = _normalizeArabicString(dateStr);
    final cleanTimeStr = _normalizeArabicString(timeStr);

    DateTime? parsedDate;
    final dateFormats = [
      DateFormat.yMd(),
      DateFormat('M/d/yyyy'),
      DateFormat('d/M/yyyy'),
      DateFormat('M-d-yyyy'),
      DateFormat('d-M-yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('yyyy/MM/dd'),
    ];
    for (final fmt in dateFormats) {
      try {
        parsedDate = fmt.parse(cleanDateStr);
        break;
      } catch (_) {}
    }
    if (parsedDate == null) return null;

    DateTime? parsedTime;
    final timeFormats = [
      DateFormat('h:mm a', 'en'),
      DateFormat('hh:mm a', 'en'),
      DateFormat('h:mm a'),
      DateFormat('hh:mm a'),
      DateFormat('H:mm'),
      DateFormat('HH:mm'),
    ];
    for (final fmt in timeFormats) {
      try {
        parsedTime = fmt.parse(cleanTimeStr);
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

  static Future<void> checkAndNotifyOverdueTasks() async {
    try {
      final now = DateTime.now();
      final tasks = AppLocalStorage.taskBox.values;

      // Get all currently pending (scheduled but not yet fired) notifications.
      final pendingRequests = await _notificationsPlugin.pendingNotificationRequests();
      final pendingIds = pendingRequests.map((r) => r.id).toSet();

      for (final task in tasks) {
        if (task.isCompleted) continue;

        // Skip tasks where the user didn't enable a reminder.
        if (task.notificationId == null) continue;

        if (task.isRepeat != null &&
            task.isRepeat!.isNotEmpty &&
            task.isRepeat != 'None') {
          continue;
        }

        // Ensure each missed task notification is only displayed ONCE
        bool alreadyNotified =
            AppLocalStorage.getCachedData('overdue_notified_${task.id}') ?? false;
        if (alreadyNotified) continue;

        final int baseId = _getBaseId(task.notificationId!);
        final int overdueId = baseId + _overdueOffset;

        // If the overdue notification is already scheduled (pending), skip —
        // it will fire at the correct endTime without duplicating.
        if (pendingIds.contains(overdueId)) continue;

        final scheduledDate = parseTaskDateTime(task.date, task.startTime);
        if (scheduledDate == null) continue;

        DateTime? endDate = parseTaskDateTime(task.date, task.endTime);
        DateTime thresholdDate = (endDate != null && endDate.isAfter(scheduledDate))
            ? endDate
            : scheduledDate.add(const Duration(minutes: 2));

        // Only show if overdue within the last 48 hours
        final diffInMinutes = now.difference(thresholdDate).inMinutes;
        if (thresholdDate.isBefore(now) && diffInMinutes >= 0 && diffInMinutes <= 2880) {
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

          // Mark as notified so it never fires again on app relaunch
          AppLocalStorage.casheData('overdue_notified_${task.id}', true);
        }
      }
    } catch (_) {}
  }


  // ─────────────────────────────────────────────
  // Task Reminder Notifications (Start & Overdue)
  // ─────────────────────────────────────────────

  /// Returns true if the app can schedule exact alarms (Android 12+ check).
  static Future<bool> _canScheduleExact() async {
    try {
      final androidImpl = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl == null) return true;
      final canSchedule = await androidImpl.canScheduleExactNotifications();
      return canSchedule ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Helper: schedules a zonedSchedule with exact alarm if permitted,
  /// falls back to inexact automatically. NEVER shows immediately.
  static Future<void> _scheduleZoned({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required NotificationDetails details,
    String? payload,
  }) async {
    final nowTz = tz.TZDateTime.now(tz.local);
    if (!scheduledTime.isAfter(nowTz)) {
      debugPrint(
        '[NotifService] Skipping _scheduleZoned for id=$id — '
        'scheduled time ($scheduledTime) is not in future (now=$nowTz)',
      );
      return;
    }

    final bool canExact = await _canScheduleExact();
    final AndroidScheduleMode mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        payload: payload,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint(
        '[NotifService] zonedSchedule (mode=$mode) failed for id=$id: $e. Retrying inexact...',
      );
      if (mode != AndroidScheduleMode.inexactAllowWhileIdle) {
        try {
          await _notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTime,
            details,
            payload: payload,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (err2) {
          debugPrint('[NotifService] Inexact zonedSchedule also failed for id=$id: $err2');
        }
      }
    }
  }

  static Future<void> scheduleTaskNotification(TaskModel task) async {
    if (task.notificationId == null) return;

    try {
      DateTime now = DateTime.now();

      // 1. Parse Start Date & Time
      DateTime? dateParsed = parseTaskDateTime(task.date, task.startTime);
      if (dateParsed == null) {
        debugPrint('[NotifService] Could not parse task start date/time for task ${task.title}');
        return;
      }

      DateTime scheduledStart = dateParsed;

      // 2. Parse End Date & Time (Fallback: Start + 1 hour)
      DateTime? endDateParsed = parseTaskDateTime(task.date, task.endTime);
      DateTime scheduledEnd = (endDateParsed != null && endDateParsed.isAfter(scheduledStart))
          ? endDateParsed
          : scheduledStart.add(const Duration(hours: 1));

      final int baseId          = _getBaseId(task.notificationId!);
      final int startNotifId    = baseId;
      final int overdueNotifId  = baseId + _overdueOffset;
      final int reminderNotifId = baseId + _reminderOffset;

      // ── 3-A. 6-HOUR ADVANCE REMINDER ──────────────────────────────────────
      final Duration timeUntilStart = scheduledStart.difference(now);
      if (timeUntilStart.inMinutes > _reminderHoursBefore * 60) {
        final DateTime reminderTime =
            scheduledStart.subtract(Duration(hours: _reminderHoursBefore));
        final tz.TZDateTime tzReminder = tz.TZDateTime.from(reminderTime, tz.local);

        final String countdownText = timeUntilStart.inHours >= 24
            ? '${(timeUntilStart.inHours / 24).floor()} day(s) and ${timeUntilStart.inHours % 24}h'
            : '${timeUntilStart.inHours}h ${timeUntilStart.inMinutes % 60}min';

        final String reminderTitle = '🔔 Upcoming Task: ${task.title}';
        final String reminderBody  = task.discription.isNotEmpty
            ? '⏳ Starts in $_reminderHoursBefore hours at ${task.startTime}\n'
              '📝 ${task.discription}'
            : '⏳ Starts in $_reminderHoursBefore hours at ${task.startTime}\n'
              '📌 Total time remaining: $countdownText';

        final BigTextStyleInformation reminderBigText = BigTextStyleInformation(
          reminderBody,
          htmlFormatBigText: true,
          contentTitle: '🔔 <b>${task.title}</b> — in $_reminderHoursBefore hours',
          htmlFormatContentTitle: true,
          summaryText: 'Taskatii Reminder ⏳',
          htmlFormatSummaryText: true,
        );

        final AndroidNotificationDetails reminderAndroid = AndroidNotificationDetails(
          _reminderChannelId,
          'Task Reminders',
          channelDescription: '6-hour advance reminder for upcoming tasks',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: reminderBigText,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 300, 150, 300]),
          icon: '@mipmap/ic_launcher',
          visibility: NotificationVisibility.public,
        );

        final NotificationDetails reminderDetails = NotificationDetails(
          android: reminderAndroid,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        );

        await _scheduleZoned(
          id: reminderNotifId,
          title: reminderTitle,
          body: reminderBody,
          scheduledTime: tzReminder,
          details: reminderDetails,
          payload: 'task:${task.id}',
        );

        debugPrint(
          '[NotifService] 6-h reminder scheduled for "${task.title}" '
          'at ${reminderTime.toLocal()}',
        );
      }

      // ── 3. START notification ──────────────────────────────────────────────
      // Only schedule if startTime is strictly in the future.
      final bool startInFuture = scheduledStart.isAfter(now);

      if (startInFuture) {
        final String remainingText = scheduledStart.difference(now).inHours >= 1
            ? 'Starts in ${scheduledStart.difference(now).inHours}h'
            : 'Starts in ${scheduledStart.difference(now).inMinutes} mins';

        final String startTitle = '⏰ TASK ALARM: ${task.title}';
        final String startBody = task.discription.isNotEmpty
            ? '📌 ${task.startTime} - ${task.endTime}\n📝 ${task.discription}'
            : '📌 Scheduled: ${task.startTime} | Time to get to work! 🚀';

        final BigTextStyleInformation bigTextStyleStart = BigTextStyleInformation(
          startBody,
          htmlFormatBigText: true,
          contentTitle: '⏰ <b>${task.title}</b>',
          htmlFormatContentTitle: true,
          summaryText: 'Taskatii Alarm 🕒 $remainingText',
          htmlFormatSummaryText: true,
        );

        final AndroidNotificationDetails startAndroidDetails = AndroidNotificationDetails(
          _alarmChannelId,
          'Task Alarms',
          channelDescription: 'Full-volume alarm for task start & overdue alerts',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          fullScreenIntent: true,
          styleInformation: bigTextStyleStart,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
          subText: '⏰ $remainingText',
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
        );

        final NotificationDetails startDetails = NotificationDetails(
          android: startAndroidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        );

        final tz.TZDateTime tzStart = tz.TZDateTime.from(scheduledStart, tz.local);
        await _scheduleZoned(
          id: startNotifId,
          title: startTitle,
          body: startBody,
          scheduledTime: tzStart,
          details: startDetails,
          payload: 'task:${task.id}',
        );
        debugPrint('[NotifService] Start notification scheduled for "${task.title}" at ${scheduledStart.toLocal()}');
      }

      // ── 4. OVERDUE notification ────────────────────────────────────────────
      // Only schedule if the end time is at least 2 minutes in the future.
      if (!task.isCompleted) {
        final Duration timeUntilEnd = scheduledEnd.difference(now);

        if (timeUntilEnd.inMinutes >= 2) {
          final String overdueTitle = '⚠️ OVERDUE TASK: ${task.title}';
          final String overdueBody =
              '📌 Scheduled end time (${task.endTime}) has passed!\nTap to complete or reschedule.';

          final BigTextStyleInformation bigTextStyleOverdue = BigTextStyleInformation(
            overdueBody,
            htmlFormatBigText: true,
            contentTitle: '<b>⚠️ Overdue Task!</b>',
            htmlFormatContentTitle: true,
            summaryText: 'Taskatii Missed Task',
            htmlFormatSummaryText: true,
          );

          final AndroidNotificationDetails overdueAndroidDetails = AndroidNotificationDetails(
            _alarmChannelId,
            'Task Alarms',
            channelDescription: 'Full-volume alarm for task start & overdue alerts',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            styleInformation: bigTextStyleOverdue,
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
            icon: '@mipmap/ic_launcher',
          );

          final NotificationDetails overdueDetails = NotificationDetails(
            android: overdueAndroidDetails,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          );

          final tz.TZDateTime tzEnd = tz.TZDateTime.from(scheduledEnd, tz.local);
          await _scheduleZoned(
            id: overdueNotifId,
            title: overdueTitle,
            body: overdueBody,
            scheduledTime: tzEnd,
            details: overdueDetails,
            payload: 'task:${task.id}',
          );

          debugPrint(
            '[NotifService] Overdue notification scheduled for "${task.title}" '
            'at ${scheduledEnd.toLocal()}',
          );
        }
      }

    } catch (e) {
      debugPrint('scheduleTaskNotification error: $e');
    }
  }

  static Future<void> cancelNotification(int? notificationId) async {
    if (notificationId != null) {
      final int baseId     = _getBaseId(notificationId);
      final int overdueId  = baseId + _overdueOffset;
      final int reminderId = baseId + _reminderOffset;
      await _notificationsPlugin.cancel(baseId);
      await _notificationsPlugin.cancel(notificationId);
      await _notificationsPlugin.cancel(overdueId);
      await _notificationsPlugin.cancel(reminderId);
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

