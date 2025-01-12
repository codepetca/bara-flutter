import 'package:flutter/material.dart';

class SupabaseAuth extends ChangeNotifier {
  // TODO: Simplify this to valuenotifier
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthenticating => _isAuthenticating;

  // TODO: Set auth to false in production!
  bool _isAuthenticated = false;
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    print("isAuthenticated: $value");
    notifyListeners();
  }

  bool _isAuthenticating = false;
  set isAuthenticating(bool value) {
    _isAuthenticating = value;
    notifyListeners();
  }

  Future<void> signIn(String email) async {
    // Sign in logic
    print("Signing in with email: $email");
    isAuthenticating = true;
    await Future.delayed(const Duration(seconds: 2));
    isAuthenticated = true;
    isAuthenticating = false;
  }

  void signOut() {
    // Sign out logic
    print("Signing out...");
    isAuthenticated = false;
  }
}
