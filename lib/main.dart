import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:taskatii/features/add_task/add_task.dart';
import 'package:taskatii/features/home/home_view.dart';
import 'package:taskatii/features/intro/splash_view.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: AddTask());
  }
}
