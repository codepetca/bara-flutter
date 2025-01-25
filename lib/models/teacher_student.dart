import 'package:bara_flutter/models/generated_classes.dart';

class TeacherStudent {
  final String teacherId;
  final String sectionCode;
  final DateTime date;
  final String studentId;
  final String firstName;
  final String lastName;
  final String studentNumber;
  final DateTime? entryTime;
  final String block;

  TeacherStudent({
    required this.teacherId,
    required this.sectionCode,
    required this.date,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.studentNumber,
    required this.entryTime,
    required this.block,
  });

  static TeacherStudent from(VForTeacherHome vForTeacherHome) {
    return TeacherStudent(
      teacherId: vForTeacherHome.teacherId!,
      sectionCode: vForTeacherHome.sectionCode!,
      date: vForTeacherHome.date!,
      studentId: vForTeacherHome.studentId!,
      firstName: vForTeacherHome.firstName!,
      lastName: vForTeacherHome.lastName!,
      studentNumber: vForTeacherHome.studentNumber!,
      entryTime: vForTeacherHome.entryTime,
      block: vForTeacherHome.block!,
    );
  }
}
