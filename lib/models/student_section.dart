import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:bara_flutter/util/datetime_x.dart';

class StudentSection {
  final DateTime date;
  final String studentId;
  final String studentNumber;
  final String block;
  final String sectionCode;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? entryTime;

  var scanSubmitted = false;

  StudentSection({
    required this.date,
    required this.studentId,
    required this.studentNumber,
    required this.block,
    required this.sectionCode,
    required this.startTime,
    required this.endTime,
    this.entryTime,
    this.scanSubmitted = false,
  });

  // Factory constructor to create a StudentSection from VForStudentHome
  factory StudentSection.from(VForStudentHome vForStudentHome) {
    return StudentSection(
      date: vForStudentHome.date!,
      studentId: vForStudentHome.studentId!,
      studentNumber: vForStudentHome.studentNumber!,
      block: vForStudentHome.block!,
      sectionCode: vForStudentHome.sectionCode!,
      startTime: vForStudentHome.startTime!.toToday(),
      endTime: vForStudentHome.endTime!.toToday(),
      entryTime: vForStudentHome.entryTime,
    );
  }

  @override
  String toString() {
    return 'StudentSection{date: $date, studentNumber: $studentNumber, sectionCode: $sectionCode, startTime: $startTime, endTime: $endTime, studentId: $studentId, block: $block}';
  }

  // Sample data
  static List<StudentSection> sampleData() {
    return [
      StudentSection(
        date: DateTime.now(),
        studentId: '1',
        studentNumber: '20210001',
        block: 'P1',
        sectionCode: 'ICS3U1',
        startTime: DateTimeX.fromTimeStringWithSeconds('08:10:00')!,
        endTime: DateTimeX.fromTimeStringWithSeconds('09:30:00')!,
      ),
      StudentSection(
        date: DateTime.now(),
        studentId: '1',
        studentNumber: '20210001',
        block: 'P2',
        sectionCode: 'MPM2D1',
        startTime: DateTimeX.fromTimeStringWithSeconds('09:35:00')!,
        endTime: DateTimeX.fromTimeStringWithSeconds('10:50:00')!,
      ),
      StudentSection(
        date: DateTime.now(),
        studentId: '1',
        studentNumber: '20210001',
        block: 'P3',
        sectionCode: 'BAF3M1',
        startTime: DateTimeX.fromTimeStringWithSeconds('10:55:00')!,
        endTime: DateTimeX.fromTimeStringWithSeconds('12:10:00')!,
      ),
      StudentSection(
        date: DateTime.now(),
        studentId: '1',
        studentNumber: '20210001',
        block: 'P4',
        sectionCode: 'LUNCH',
        startTime: DateTimeX.fromTimeStringWithSeconds('12:15:00')!,
        endTime: DateTimeX.fromTimeStringWithSeconds('13:30:00')!,
      ),
      StudentSection(
        date: DateTime.now(),
        studentId: '1',
        studentNumber: '20210001',
        block: 'P5',
        sectionCode: 'SNC2D1',
        startTime: DateTimeX.fromTimeStringWithSeconds('13:35:00')!,
        endTime: DateTimeX.fromTimeStringWithSeconds('14:50:00')!,
      ),
    ];
  }
}
