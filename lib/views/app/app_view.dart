import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/services/supabase_service.dart';
import 'package:bara_flutter/views/app/loading_view.dart';
import 'package:bara_flutter/views/guest/guest_view.dart';
import 'package:bara_flutter/views/student/student_home.dart';
import 'package:bara_flutter/views/teacher/teacher_home.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:watch_it/watch_it.dart';

class AppView extends WatchingWidget {
  final log = Logger('AppView');

  AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final appUser = watchIt<SupabaseAuth>().appUser;
    final supabaseService = watchIt<SupabaseService>();
    final isLoading = supabaseService.isLoading;
    log.info('appUser: ${appUser?.profile.email}');
    if (appUser == null) {
      return Scaffold(
        body: Center(
          child: Text('Loading...'),
        ),
      );
    }
    // final isAuthenticated =
    //     watchPropertyValue((SupabaseAuth auth) => auth.isAuthenticated);
    // final isLoading = watchPropertyValue((SupabaseAuth auth) => auth.isLoading);

    log.info('isLoading: $isLoading');
    log.info('appUser: $appUser');
    final role = appUser.profile.role;
    if (isLoading) {
      return LoadingView();
    }

    return switch (role) {
      ROLE_ENUM.student => StudentHome(),
      ROLE_ENUM.teacher => TeacherHome(),
      _ => GuestView(),
    };
  }
}
