import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/services/notification_service.dart';
import 'package:taskatii/core/services/supabase_service.dart';
import 'package:taskatii/core/utils/themes.dart';
import 'package:taskatii/features/intro/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox('userBox');
  await Hive.openBox<TaskModel>('taskBox');
  AppLocalStorage.init();

  await NotificationService.init();
  await SupabaseService.init();

  runApp(const MainApp());
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
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      themeAnimationDuration: Duration.zero,
      home: const SplashView(),
    );
  }
}
