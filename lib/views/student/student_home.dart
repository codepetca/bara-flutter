import 'package:bara_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bara_flutter/services/supabase_x.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final log = Logger('StudentHome');

  @override
  void initState() {
    super.initState();
    _onFetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text('Welcome, Student!'),
            Spacer(),

            // Scan button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onBeginScan,
                  child: Text('Begin Scan'),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // TODO: Use actual student ID and date
  // save fetched data to shared preferences
  Future<void> _onFetchStudentData() async {
    log.info('Fetching student data...');
    final studentId = '56ad7055-3d70-4b53-8e4f-8d24832a285f';
    final date = '2025-01-10';
    final studentSections =
        await Supabase.instance.fetchStudentHomeData(studentId, date);
  }

  void _onBeginScan() {
    throw UnimplementedError();
  }
}
