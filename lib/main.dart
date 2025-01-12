import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/views/app/app.dart';
import 'package:bara_flutter/views/app/settings_view.dart';
import 'package:bara_flutter/views/app/sign_in_view.dart';
import 'package:bara_flutter/views/student/student_home_view.dart';
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
        '/': (context) => App(),
        '/sign_in': (context) => SignInView(),
        '/student_home': (context) => StudentHomeView(),
        '/settings': (context) => SettingsView(),
      },
    );
  }
}
