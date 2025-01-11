import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/util/validators.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SignInView extends StatelessWidget {
  SignInView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = GetIt.instance<SupabaseAuth>();

  void _signIn(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _authService.signIn(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signing in...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: validateEmail,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signIn(context),
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
