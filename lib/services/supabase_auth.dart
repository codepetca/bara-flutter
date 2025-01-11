import 'package:flutter/material.dart';

class SupabaseAuth extends ChangeNotifier {
  bool get isAuthenticated => _isAuthenticated;

  // TODO: Set auth to false!
  bool _isAuthenticated = true;
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void signIn(String email) {
    // Sign in logic
    print("Signing in with email: $email");
  }
}
