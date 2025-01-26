import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final supabaseAuth = di.get<SupabaseAuth>();

  @override
  Widget build(BuildContext context) {
    final profile = supabaseAuth.appUser?.profile;
    final username = profile == null
        ? 'No profile'
        : "${profile.firstName} ${profile.lastName}";
    final email = profile == null ? 'No email' : profile.email;
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(username),
              Text(email),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  await supabaseAuth.signOut();
                  // Navigate to the app home route and remove all previous routes
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.app,
                      (route) => false, // Removes all previous routes
                    );
                  }
                },
                child: Text('Sign Out'),
              ),
              Spacer(),
              Spacer(),
            ],
          ),
        ));
  }
}
