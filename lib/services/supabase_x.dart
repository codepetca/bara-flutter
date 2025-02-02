import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/models/teacher_student.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension SupabaseX on Supabase {
  Logger get log => Logger('SupabaseX');

  // Fetch student home data from database
  Future<List<StudentSection>> fetchStudentHomeData(
      String studentId, DateTime date) async {
    log.info(
        'Fetching student home data for studentId: $studentId on date: $date');
    // convert date to dateString
    final dateString = date.formattedDate;
    log.info('dateString: $dateString');

    final vForStudentHomeList = await client.v_for_student_home
        .select()
        .eq("student_id", studentId)
        .eq("date", dateString)
        .withConverter(VForStudentHome.converter);

    log.info('vForStudentHomeList: $vForStudentHomeList');
    final studentSections = vForStudentHomeList
        .map((vForStudentHome) => StudentSection.from(vForStudentHome))
        .toList();
    for (var studentSection in studentSections) {
      log.info(studentSection.toString());
    }
    return studentSections;
  }

  // Fetch teacher home data from database
  Future<List<TeacherStudent>> fetchTeacherHomeData(
      String teacherId, DateTime date) async {
    log.info(
        'Fetching teacher home data for teacherId: $teacherId on date: $date');

    final vForTeacherHomeList = await client.v_for_teacher_home
        .select()
        .eq("teacher_id", teacherId)
        .eq("date", date)
        .withConverter(VForTeacherHome.converter);

    final teacherStudents = vForTeacherHomeList
        .map((vForTeacherHome) => TeacherStudent.from(vForTeacherHome))
        .toList();
    for (var teacherStudent in teacherStudents) {
      log.info(teacherStudent.toString());
    }
    return teacherStudents;
  }

  /// For student view to send attendance scan to database
  Future<bool> sendAttendanceScan({
    required String tagUid,
    required String studentNumber,
    required DateTime scanTime,
  }) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'tag_scan',
        body: {
          "studentNumber": studentNumber,
          "scannedTagUid": tagUid,
          "scanTime": scanTime.toIso8601String(),
        },
      );

      log.info("Response: ${response.data}");
      return true;
    } catch (e) {
      print("Request failed: $e");
      return false;
    }
  }
}
