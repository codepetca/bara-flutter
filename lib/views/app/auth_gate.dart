import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/services/supabase_service.dart';
import 'package:bara_flutter/views/app/app_view.dart';
import 'package:bara_flutter/views/sign_in/sign_in_view.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:watch_it/watch_it.dart';

class AuthGate extends WatchingWidget {
  final log = Logger('AuthView');
  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appUser = watchIt<SupabaseAuth>().appUser;
    log.info('appUser: ${appUser?.profile.email}');
    if (appUser != null) {
      // Authenticated
      return AppView();
    } else {
      // Not authenticated
      return SignInView();
    }
  }
}
