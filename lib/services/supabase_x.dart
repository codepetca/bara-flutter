import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/models/teacher_student.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

extension SupabaseX on Supabase {
  Logger get log => Logger('SupabaseX');

  Future<void> fetchTeachers() async {
    log.info('Fetching teachers...');

    final teachers =
        await client.teacher.select().withConverter(Teacher.converter);
    log.info(teachers.map((teacher) => teacher.toJson()).toList().toString());
  }

  Future<List<StudentSection>> fetchStudentHomeData(
      String studentId, String date) async {
    log.info(
        'Fetching student home data for studentId: $studentId on date: $date');

    final vForStudentHomeList = await client.v_for_student_home
        .select()
        .eq("student_id", studentId)
        .eq("date", date)
        .withConverter(VForStudentHome.converter);

    final studentSections = vForStudentHomeList
        .map((vForStudentHome) => StudentSection.from(vForStudentHome))
        .toList();
    for (var studentSection in studentSections) {
      log.info(studentSection.toString());
    }
    return studentSections;
  }

  Future<List<TeacherStudent>> fetchTeacherHomeData(
      Uuid teacherId, DateTime date) async {
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
}
