import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  final SharedPreferences sharedPreferences;
  LocalStore(this.sharedPreferences);

  // ----------------------------------------------
  // Watchable values
  // ----------------------------------------------
  final signInEmail = ValueNotifier<String>('');

  // ----------------------------------------------

  Future<void> saveSignInEmail(String email) async {
    await sharedPreferences.setString('signInEmail', email);
    signInEmail.value = email;
  }

  String? getSignInEmail() {
    final email = sharedPreferences.getString('signInEmail');
    signInEmail.value = email ?? '';
    return email;
  }

  void clear() async {
    await sharedPreferences.clear();
    signInEmail.value = '';
  }
}
