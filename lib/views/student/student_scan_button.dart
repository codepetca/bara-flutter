import 'package:flutter/material.dart';

class StudentScanButton extends StatelessWidget {
  final bool scanReady;
  final void Function() onPressed;

  const StudentScanButton(
      {super.key, required this.onPressed, required this.scanReady});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: Opacity(
          opacity: scanReady ? 1 : 0.3,
          child: ElevatedButton(
            onPressed: scanReady ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22.0),
              child: Text(
                'Begin Scan',
                style: theme.textTheme.headlineSmall!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
