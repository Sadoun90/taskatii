import 'package:hive/hive.dart';
import 'package:taskatii/core/models/task_model.dart';

class AppLocalStorage {
  // ignore: non_constant_identifier_names
  static String KIsUpload = 'isUpload';
  static String KIsDarkMode = 'isDarkMode';
  // ignore: non_constant_identifier_names
  static String KName = 'name';
  // ignore: non_constant_identifier_names
  static String KImage = 'image';

  static late Box userBox;
  static late Box<TaskModel> taskBox;

  static init() {
    userBox = Hive.box('userBox');
    taskBox = Hive.box('taskBox');
  }

  static casheData(String key, value) {
    userBox.put(key, value);
  }

  static getCachedData(String key) {
    return userBox.get(key);
  }

  static casheTaskData(String key, TaskModel value) {
    taskBox.put(key, value);
  }

  static TaskModel? getCacheTaskdData(String key) {
    return taskBox.get(key);
  }

  static getCacheTaskData(key) {}
}
