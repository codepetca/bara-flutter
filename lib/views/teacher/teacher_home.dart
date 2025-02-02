import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/models/teacher_student.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final log = Logger('TeacherHome');

  late final List<TeacherStudent> students;

  @override
  void initState() {
    super.initState();
    _onFetchTeacherData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date
            Text(
              DateTime.now().formattedDate,
              style: theme.textTheme.titleLarge,
            ),
            Spacer(),
            Text('Teacher Home'),
            Spacer(),
          ],
        ),
      ),
    );
  }

  void _onFetchTeacherData() async {
    log.severe('TODO: Fetching teacher data...');
    // throw UnimplementedError();
  }
}
