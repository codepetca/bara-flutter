import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/models/local_store.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/views/sign_in/email_text_view.dart';
import 'package:bara_flutter/views/sign_in/password_text_view.dart';
import 'package:bara_flutter/views/sign_in/button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:watch_it/watch_it.dart';

enum SignInMethod {
  email,
  magicLink,
}

class SignInView extends WatchingStatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final log = Logger('SignInView');

  final _signInMethod = SignInMethod.email;
  final _supabaseAuth = di<SupabaseAuth>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final savedSignInEmail =
        watchValue((LocalStore store) => store.signInEmail);
    _emailController.text = savedSignInEmail;

    // final authResponse =
    //     watchPropertyValue((SupabaseAuth auth) => auth.authResponse);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, Routes.info),
          icon: Icon(Icons.info_outline),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Spacer(),
              EmailTextView(_emailController),
              SizedBox(height: 16),
              if (_signInMethod == SignInMethod.email)
                PasswordTextView(_passwordController),
              Spacer(),
              // Create account button
              _createAccountButton(),
              Button(
                label: 'Sign In',
                onTap: _onSignInButtonTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Create account button
  Widget _createAccountButton() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, Routes.signUp),
      child: Text('Create Account'),
    );
  }

  // Sign in
  void _onSignInButtonTapped() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      switch (_signInMethod) {
        case SignInMethod.email:
          final password = _passwordController.text;
          await _supabaseAuth.signInWithEmail(email, password);
          break;
        case SignInMethod.magicLink:
          await _supabaseAuth.signInWithMagicLink(email);
          break;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
