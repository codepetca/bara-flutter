import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_it/watch_it.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final supabaseAuth = di.get<SupabaseAuth>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              supabaseAuth.signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    ));
  }
}
