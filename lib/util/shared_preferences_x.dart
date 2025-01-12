import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesX on SharedPreferences {
  Future<void> saveSignInEmail(String email) async {
    await setString('signInEmail', email);
  }

  String? getSignInEmail() {
    return getString('signInEmail');
  }
}
