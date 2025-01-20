import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/util/datetime_x.dart';

class StudentSection {
  final DateTime date;
  final String studentNumber;
  final String sectionCode;
  final DateTime startTime;
  final DateTime endTime;
  final String studentId;
  final String block;

  var scanSubmitted = false;

  StudentSection({
    required this.date,
    required this.studentNumber,
    required this.sectionCode,
    required this.startTime,
    required this.endTime,
    required this.studentId,
    required this.block,
    this.scanSubmitted = false,
  });

  // Factory constructor to create a StudentSection from VForStudentHome
  factory StudentSection.fromVForStudentHome(VForStudentHome vForStudentHome) {
    return StudentSection(
      date: vForStudentHome.date!,
      studentId: vForStudentHome.studentId!,
      studentNumber: vForStudentHome.studentNumber!,
      sectionCode: vForStudentHome.sectionCode!,
      startTime: vForStudentHome.startTime!.toToday(),
      endTime: vForStudentHome.endTime!.toToday(),
      block: vForStudentHome.block!,
    );
  }

  @override
  String toString() {
    return 'StudentSection{date: $date, studentNumber: $studentNumber, sectionCode: $sectionCode, startTime: $startTime, endTime: $endTime, studentId: $studentId, block: $block}';
  }
}
