import 'dart:async';

import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/local_store.dart';
import 'package:bara_flutter/models/profile.dart';
import 'package:bara_flutter/models/result.dart';
import 'package:bara_flutter/services/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_it/watch_it.dart';

class SupabaseAuth extends ChangeNotifier {
  final log = Logger('SupabaseAuth');

  late final StreamSubscription<AuthState> _authStateSubscription;

  final SupabaseService supabaseService;
  SupabaseAuth({required this.supabaseService});

  // ------------------------------
  // Listenable states
  // ------------------------------
  AppUser? get appUser => _appUser;
  bool get isAuthenticated => appUser != null; // Convenience getter
  bool get isLoading => _isLoading;

  // the app user
  AppUser? _appUser;
  set appUser(AppUser? value) {
    _appUser = value;
    log.info('AppUser updated: ${value?.profile.email}');
    notifyListeners();
  }

  bool _isLoading = false;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ------------------------------
  // Auth Methods
  // ------------------------------

  // Begin listening to auth state changes
  void listenToAuthStateChanges() async {
    log.info("Listening to auth state changes...");
    final supabase = Supabase.instance.client;
    // Listen to auth state changes
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) async {
        final event = data.event;
        log.info("Auth state event: $event");
        switch (event) {
          case AuthChangeEvent.initialSession:
            if (data.session == null) return;
            final supabaseUser = data.session?.user;
            final success = await _updateAppUser(supabaseUser);
            // After successful, start the app
            if (success) await supabaseService.startAppSession(appUser!);
          case AuthChangeEvent.signedIn:
            final supabaseUser = data.session?.user;
            final success = await _updateAppUser(supabaseUser);
            // After successful, start the app
            if (success) await supabaseService.startAppSession(appUser!);
          case AuthChangeEvent.signedOut:
            await _updateAppUser(null);
          default:
            break;
        }
      },
      onError: (error) {
        if (error is AuthException) {
          log.warning("Auth error: ${error.message}");
        } else {
          log.warning("Unexpected error: $error");
        }
      },
    );
  }

  /// ------------------------------
  /// Sign in with magiclink
  /// ------------------------------
  Future<void> signInWithMagicLink(String email) async {
    log.info("Signing in with magic link email: $email");
    isLoading = true;

    try {
      // Send magic link to email
      final redirectUrl = dotenv.env['SUPABASE_REDIRECT_URL']!;
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : redirectUrl,
      );
      // Success so save the email to local storage
      await di<LocalStore>().saveSignInEmail(email);
    } on Exception catch (e) {
      log.info('Magic link auth error: $e');
    } finally {
      isLoading = false;
    }
  }

  /// --------------------------------
  /// Email and password
  /// --------------------------------
  ///
  /// Sign up with email and password
  Future<Result<String, Exception>> signUpWithEmail(
      String email, String password) async {
    log.info('Signing Up with email: $email');
    isLoading = true;
    try {
      await Supabase.instance.client.auth
          .signUp(email: email, password: password);
      return Success('Sign in successful');
    } on Exception catch (e) {
      return Failure(e);
    } finally {
      isLoading = false;
    }
  }

  /// Sign in with email and password
  Future<Result<String, Exception>> signInWithEmail(
      String email, String password) async {
    log.info("Signing in with email: $email");
    isLoading = true;

    try {
      // Sign in with email and password
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Save the email to local storage
      await di<LocalStore>().saveSignInEmail(email);
      return Success("Sign in successful");
    } on Exception catch (e) {
      return Failure(e);
    } finally {
      isLoading = false;
    }
  }

  // Sign out the user
  void signOut() async {
    log.info("Signing out...");
    await Supabase.instance.client.auth.signOut();
    appUser = null; // Reset app user
  }

  // Update app user from supabase user after successful sign in
  Future<bool> _updateAppUser(User? supabaseUser) async {
    if (supabaseUser != null) {
      log.info("Setting AppUser with email: ${supabaseUser.email}");

      if (supabaseUser.email == null) {
        throw Exception("User email is null when trying to fetch profile");
      }
      // Fetch the user's profile
      final profile = await _fetchUserProfile(email: supabaseUser.email!);

      // Save the email to local storage
      await di<LocalStore>().saveSignInEmail(supabaseUser.email!);

      // Set the AppUser
      appUser = AppUser(profile: profile);

      return true;
    } else {
      log.info("Setting AppUser to null");
      appUser = null;
      return false;
    }
  }

  Future<Profile> _fetchUserProfile({required String email}) async {
    log.info("Fetching user profile for email: $email");
    final vProfileList = await Supabase.instance.client.v_profile
        .select()
        .eq("email", email)
        .withConverter(VProfile.converter);
    log.info('vProfileList: ${vProfileList.first.email}');
    final profile =
        vProfileList.map((vProfile) => Profile.from(vProfile)).toList().first;

    return profile;
  }

  // ------------------------------
  // Clean up
  // ------------------------------
  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
