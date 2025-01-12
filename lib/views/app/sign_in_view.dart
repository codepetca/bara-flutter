import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/util/validators.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bara_flutter/util/shared_preferences_x.dart';
import 'package:watch_it/watch_it.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _supabaseAuth = di<SupabaseAuth>();

  late final SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    _loadSignInEmail();
  }

  Future<void> _loadSignInEmail() async {
    prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getSignInEmail();
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  void _onSignIn(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _supabaseAuth.signIn(_emailController.text);

      // Save email to SharedPreferences
      await prefs.saveSignInEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Spacer(),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'School Email',
                  border: OutlineInputBorder(),
                ),
                validator: validateEmail,
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onSignIn(context),
                    child: Text('Sign In'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
