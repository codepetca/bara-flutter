import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function() onTap;
  final String label;
  const Button({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
