import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bara_flutter/services/supabase_x.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text('Welcome, Student!'),
            Spacer(),
            ElevatedButton(
              onPressed: _onBeginScan,
              child: Text('Begin Scan'),
            ),
          ],
        ),
      ),
    );
  }

  void _onBeginScan() {
    print('Begin Scan');
    Supabase.instance.fetchTeachers();
  }
}
