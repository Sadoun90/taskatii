import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:taskatii/core/services/local_storage.dart';
import 'package:taskatii/core/utils/colors.dart';
import 'package:taskatii/core/utils/text_style.dart';
import 'package:taskatii/core/utils/themes.dart';
import 'package:taskatii/features/intro/splash_view.dart';
import 'package:taskatii/core/models/task_model.dart';
import 'package:taskatii/features/upload/upload_view.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox('userBox');
  await Hive.openBox<TaskModel>('taskBox');
  AppLocalStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppLocalStorage.userBox.listenable(),
      builder: (context, userBox, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: userBox.get(AppLocalStorage.KIsDarkMode)
              ? ThemeMode.dark
              : ThemeMode.light,
          darkTheme: AppTheme.DarkTheme,
          theme: AppTheme.LightTheme,
          home: const SplashView(),
        );
      },
    );
  }
}
