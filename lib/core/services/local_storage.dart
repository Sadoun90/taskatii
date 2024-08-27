import 'package:hive/hive.dart';

class AppLocalStorage {

  // ignore: non_constant_identifier_names
  static String KIsUpload = 'isUpload';
  // ignore: non_constant_identifier_names
  static String KName = 'name';
  // ignore: non_constant_identifier_names
  static String KImage = 'image';

  static late Box userBox;
  static init() {
    userBox = Hive.box('userBox');
  }

  static casheData(String key, value) {
    userBox.put(key, value);
  }

  static getCachedData(String key) {
    return userBox.get(key);
  }
}
