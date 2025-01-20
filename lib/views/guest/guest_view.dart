import 'package:bara_flutter/views/app/profile_view.dart';
import 'package:flutter/material.dart';

class GuestView extends StatelessWidget {
  const GuestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Text(
          'You may have logged in with the wrong account.',
          style: TextStyle(fontSize: 16), // Adjust text style as needed
          textAlign: TextAlign.center, // Align text to the center
        ),
        SizedBox(height: 8), // Space between the two Text widgets
        Text(
          'Please sign out and try again.',
          style: TextStyle(fontSize: 16), // Adjust text style as needed
          textAlign: TextAlign.center, // Align text to the center
        ),
        Spacer(),
        ProfileView(),
        Spacer(),
      ],
    );
  }
}
