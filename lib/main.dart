import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/notification_service.dart';
import 'package:taskatii/core/utils/themes.dart';
import 'package:taskatii/features/intro/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox('userBox');
  await Hive.openBox<TaskModel>('taskBox');
  AppLocalStorage.init();

  runApp(const MainApp());

  // Initialize notifications asynchronously in the background
  NotificationService.init().then((_) async {
    final now = DateTime.now();

    // 1. Reschedule all FUTURE task notifications (in case they were lost
    //    after a device reboot or the app was force-killed).
    //    Only reschedule tasks whose start time is strictly in the future —
    //    already-started tasks must NOT be rescheduled to avoid duplicate
    //    overdue notifications firing alongside checkAndNotifyOverdueTasks.
    for (final task in AppLocalStorage.taskBox.values) {
      if (task.isCompleted) continue;
      if (task.notificationId == null) continue;

      final scheduledStart =
          NotificationService.parseTaskDateTime(task.date, task.startTime);
      if (scheduledStart == null) continue;

      // Strictly future only — if already started, skip rescheduling
      if (scheduledStart.isAfter(now)) {
        // Cancel first to avoid duplicates if app is opened multiple times
        await NotificationService.cancelNotification(task.notificationId);
        await NotificationService.scheduleTaskNotification(task);
      }
    }

    // 2. Check for any overdue tasks (start time already passed, task not done)
    //    and show a missed-task notification if not already shown.
    await NotificationService.checkAndNotifyOverdueTasks();
  });

}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark =
        AppLocalStorage.userBox.get(AppLocalStorage.KIsDarkMode, defaultValue: true);
    AppLocalStorage.userBox.listenable(keys: [AppLocalStorage.KIsDarkMode])
        .addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    final newVal =
        AppLocalStorage.userBox.get(AppLocalStorage.KIsDarkMode, defaultValue: true);
    if (newVal != _isDark) {
      setState(() {
        _isDark = newVal;
      });
    }
  }

  @override
  void dispose() {
    AppLocalStorage.userBox.listenable(keys: [AppLocalStorage.KIsDarkMode])
        .removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      themeAnimationDuration: Duration.zero,
      home: const SplashView(),
    );
  }
}
