import 'package:flutter/material.dart';

class PasswordTextView extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const PasswordTextView(
    this.controller, {
    super.key,
    this.label = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: _validatePassword,
      obscureText: true,
    );
  }
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
