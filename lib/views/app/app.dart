import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/views/app/loading_view.dart';
import 'package:bara_flutter/views/sign_in/sign_in_view.dart';
import 'package:bara_flutter/views/student/student_home.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:watch_it/watch_it.dart';

class App extends WatchingWidget {
  final log = Logger('App');

  App({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        watchPropertyValue((SupabaseAuth auth) => auth.isAuthenticated);
    final isLoading = watchPropertyValue((SupabaseAuth auth) => auth.isLoading);
    log.info('Building app with isAuthenticated: $isAuthenticated');
    if (isLoading) {
      return LoadingView();
    } else if (!isAuthenticated) {
      return SignInView();
    } else {
      return StudentHome();
    }
  }
}
