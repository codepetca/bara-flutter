import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/views/app/sign_in_view.dart';
import 'package:bara_flutter/views/student/student_home_view.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class App extends StatelessWidget with WatchItMixin {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    var isAuthenticated =
        watchPropertyValue((SupabaseAuth auth) => auth.isAuthenticated);
    if (!isAuthenticated) {
      return SignInView();
    } else {
      return StudentHomeView();
    }
  }
}
