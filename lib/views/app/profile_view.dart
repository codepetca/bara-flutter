import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_it/watch_it.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final supabaseAuth = di.get<SupabaseAuth>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: Fix this redirectUrl to work with Supabase
          // SupaMagicAuth(
          //   redirectUrl: kIsWeb ? null : 'ca.codepet.mydomain.myapp://callback',
          //   onSuccess: (Session response) {},
          //   onError: (error) {},
          // ),
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
