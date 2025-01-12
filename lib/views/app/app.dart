import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/views/app/loading_view.dart';
import 'package:bara_flutter/views/app/sign_in_view.dart';
import 'package:bara_flutter/views/student/student_home_view.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class App extends WatchingWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    var isAuthenticated =
        watchPropertyValue((SupabaseAuth auth) => auth.isAuthenticated);
    var isAuthenticating =
        watchPropertyValue((SupabaseAuth auth) => auth.isAuthenticating);
    if (isAuthenticating) {
      return LoadingView();
    } else if (!isAuthenticated) {
      return SignInView();
    } else {
      return StudentHomeView();
    }
  }
}
