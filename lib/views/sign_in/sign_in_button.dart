import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final void Function() action;
  const SignInButton({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: action,
          child: Text('Sign In'),
        ),
      ),
    );
  }
}
