import 'package:flutter/material.dart';

class EmailTextView extends StatelessWidget {
  final TextEditingController controller;

  const EmailTextView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'School Email',
        border: OutlineInputBorder(),
      ),
      validator: _validateEmail,
    );
  }
}

String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
