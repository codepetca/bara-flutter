import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/views/sign_in/button.dart';
import 'package:bara_flutter/views/sign_in/email_text_view.dart';
import 'package:bara_flutter/views/sign_in/password_text_view.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/images/logo.png',
                      fit: BoxFit.contain),
                ),
              ),
              SizedBox(height: 16),
              EmailTextView(_emailController),
              SizedBox(height: 24),
              PasswordTextView(_passwordController),
              SizedBox(height: 12),
              PasswordTextView(
                _confirmPasswordController,
                label: 'Confirm Password',
              ),
              SizedBox(height: 16),
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16),
              Button(label: 'Sign Up', onTap: onSignUp),
            ],
          ),
        ),
      ),
    );
  }

  void onSignUp() {
    if (mounted) {
      setState(() {
        message = '';
      });
    }

    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      if (mounted) {
        setState(() {
          message = 'Passwords do not match';
        });
      }
      return;
    }

    // Sign up
    final authResponse = di<SupabaseAuth>().signUpWithEmail(email, password);
  }
}
