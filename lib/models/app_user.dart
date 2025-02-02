import 'package:bara_flutter/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AppUser extends ChangeNotifier {
  final log = Logger('AppUser');

  Profile _profile;

  Profile get profile => _profile;

  AppUser({
    required Profile profile,
  }) : _profile = profile;

  // Method to update the profile and notify listeners
  void updateProfile(Profile newProfile) {
    if (_profile != newProfile) {
      _profile = newProfile;
      notifyListeners();
    }
  }

  @override
  String toString() {
    return 'AppUser profile: $_profile';
  }
}
