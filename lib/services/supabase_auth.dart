import 'dart:async';

import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/profile.dart';
import 'package:bara_flutter/models/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuth extends ChangeNotifier {
  final log = Logger('SupabaseAuth');

  late final StreamSubscription<AuthState> _authStateSubscription;

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
    log.info('AppUser updated: $value');
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
            await _updateAppUser(supabaseUser);
          case AuthChangeEvent.signedIn:
            final supabaseUser = data.session?.user;
            await _updateAppUser(supabaseUser);
          case AuthChangeEvent.signedOut:
            await _updateAppUser(null);
          default:
            break;
        }
        // if (_redirecting) return;
        // final session = data.session;
        // if (session != null) {
        //   _redirecting = true;
        // }
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

  Future<Result<String, Exception>> signInWithMagicLink(String email) async {
    log.info("Signing in with magic link email: $email");
    isLoading = true;

    try {
      // Send magic link to email
      final redirectUrl = dotenv.env['SUPABASE_REDIRECT_URL']!;
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : redirectUrl,
      );
      return Success('Check your email for a login link!');
    } on Exception catch (e) {
      return Failure(e);
    } finally {
      isLoading = false;
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    log.info("Signing out...");
    await Supabase.instance.client.auth.signOut();
    appUser = null; // Reset app user
  }

  // Update app user from supabase user after successful sign in
  Future<void> _updateAppUser(User? supabaseUser) async {
    if (supabaseUser != null) {
      log.info("Setting AppUser to $supabaseUser");

      if (supabaseUser.email == null) {
        throw Exception("User email is null when trying to fetch profile");
      }
      // Fetch the user's profile
      final profile = await _fetchUserProfile(email: supabaseUser.email!);

      // Set the AppUser
      appUser = AppUser(profile: profile);
    } else {
      log.info("Setting AppUser to null");
      appUser = null;
    }
  }

  Future<Profile> _fetchUserProfile({required String email}) async {
    print("Fetching user profile for email: $email");
    final vProfileList = await Supabase.instance.client.v_profile
        .select()
        .eq("email", email)
        .withConverter(VProfile.converter);

    final profile =
        vProfileList.map((vProfile) => Profile.from(vProfile)).toList().first;

    return profile;
  }

  /// ------------------------------
  /// Only for Development
  /// ------------------------------
  // Future<void> signInWithMagicLinkTest(String email) async {
  //   log.info("Signing in with email: $email");
  //   isLoading = true;
  //   // Wait for 2 seconds to simulate the sign in process
  //   await Future.delayed(const Duration(seconds: 2));

  //   // Fetch user profile
  //   final profile = await _fetchUserProfileTest(email: email);
  //   log.info("User profile: $profile");

  //   // Set app user on successful sign in
  //   appUser = AppUser(profile: profile);

  //   isLoading = false;
  // }

  // Future<Profile> _fetchUserProfileTest({required String email}) {
  //   return Future.delayed(
  //     const Duration(seconds: 1),
  //     () {
  //       // Simulate error once in a while while fetching profile
  //       if (Random().nextDouble() < 0.1) {
  //         throw AppError.fetchError("Error fetching user profile");
  //       }
  //       return Profile.sampleStudentProfile(email: email);
  //     },
  //   );
  // }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
