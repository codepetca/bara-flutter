import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/models/local_store.dart';
import 'package:bara_flutter/models/result.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/util/validators.dart';
import 'package:bara_flutter/views/sign_in/sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:watch_it/watch_it.dart';

class SignInView extends WatchingStatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final log = Logger('SignInView');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _supabaseAuth = di<SupabaseAuth>();

  String signInMessage = '';

  @override
  Widget build(BuildContext context) {
    final savedSignInEmail =
        watchValue((LocalStore store) => store.signInEmail);
    _emailController.text = savedSignInEmail;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.info);
          },
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
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'School Email',
                  border: OutlineInputBorder(),
                ),
                validator: validateEmail,
              ),
              Spacer(),
              Spacer(),
              Text(signInMessage),
              SignInButton(action: _onSignIn),
            ],
          ),
        ),
      ),
    );
  }

  void _onSignIn() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;

      if (mounted) {
        setState(() => signInMessage = 'Check your email for a login link!');
      }
      final result = await _supabaseAuth.signInWithMagicLink(email);

      switch (result) {
        case Success(value: final message):
          await di<LocalStore>().saveSignInEmail(email);
          if (mounted) {
            setState(() => signInMessage = message);
          }
          log.info(message);
        case Failure(exception: final exception):
          if (mounted) {
            setState(() => signInMessage = '$exception');
          }
          log.severe(exception);
      }
    }
  }
}
