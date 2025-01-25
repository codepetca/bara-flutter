import 'package:bara_flutter/models/teacher_student.dart';
import 'package:flutter/material.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  late final List<TeacherStudent> students;

  @override
  void initState() {
    super.initState();
    _onFetchTeacherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  void _onFetchTeacherData() async {
    print('TODO: Fetching teacher data...');
  }
}
