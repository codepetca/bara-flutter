import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/models/profile.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/services/timer_service.dart';
import 'package:bara_flutter/views/app/app.dart';
import 'package:bara_flutter/views/app/profile_view.dart';
import 'package:bara_flutter/views/sign_in/info_view.dart';
import 'package:bara_flutter/views/sign_in/sign_in_view.dart';
import 'package:bara_flutter/views/student/student_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_it/watch_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env file
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Register the services
  di.registerSingleton<SupabaseAuth>(SupabaseAuth());
  di.registerSingleton<TimerService>(TimerService());

  // Begin authentication
  final supabaseAuth = di<SupabaseAuth>();
  supabaseAuth.listenToAuthStateChanges();

  // Run the app
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        Routes.root: (context) => App(),
        Routes.signIn: (context) => SignInView(),
        Routes.studentHome: (context) => StudentHome(),
        Routes.profile: (context) => ProfileView(),
        Routes.info: (context) => InfoView(),
      },
    );
  }
}

class Routes {
  static const String root = '/';
  static const String signIn = '/sign_in';
  static const String studentHome = '/student_home';
  static const String profile = '/profile';
  static const String info = '/info';
}
