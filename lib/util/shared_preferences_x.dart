import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesX on SharedPreferences {
  Future<void> writeData(String key, String data) async {
    await setString(key, data);
  }

  String? readData(String key) {
    return getString(key);
  }
}
