import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/models/local_store.dart';
import 'package:bara_flutter/models/profile.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/services/supabase_service.dart';
import 'package:bara_flutter/services/timer_service.dart';
import 'package:bara_flutter/views/app/app_view.dart';
import 'package:bara_flutter/views/app/auth_gate.dart';
import 'package:bara_flutter/views/app/profile_view.dart';
import 'package:bara_flutter/views/sign_in/info_view.dart';
import 'package:bara_flutter/views/sign_in/sign_in_view.dart';
import 'package:bara_flutter/views/sign_in/sign_up_view.dart';
import 'package:bara_flutter/views/student/student_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  di.registerSingleton<SupabaseService>(SupabaseService());
  di.registerSingleton<SupabaseAuth>(
    SupabaseAuth(supabaseService: di<SupabaseService>()),
  );
  di.registerSingleton<TimerService>(TimerService());
  final sharedPreferences = await SharedPreferences.getInstance();
  di.registerSingleton<LocalStore>(LocalStore(sharedPreferences));

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
      themeMode: ThemeMode.system,
      initialRoute: Routes.auth,
      routes: {
        Routes.auth: (context) => AuthGate(),
        Routes.app: (context) => AppView(),
        Routes.signIn: (context) => SignInView(),
        Routes.signUp: (context) => SignUpView(),
        Routes.studentHome: (context) => StudentHome(),
        Routes.profile: (context) => ProfileView(),
        Routes.info: (context) => InfoView(),
      },
    );
  }
}

class Routes {
  static const String auth = '/';
  static const String app = '/app';
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';
  static const String studentHome = '/student_home';
  static const String profile = '/profile';
  static const String info = '/info';
}

class AppTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.amber,
      brightness: Brightness.light,
    ),
    fontFamily: GoogleFonts.roboto().fontFamily,
    fontFamilyFallback: [GoogleFonts.lato().fontFamily!],
    useMaterial3: true,
  );

  static final dark = light.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.amber,
      brightness: Brightness.dark,
    ),
  );
}
