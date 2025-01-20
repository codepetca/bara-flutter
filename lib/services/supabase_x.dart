import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        .limit(20)
        .withConverter(VForStudentHome.converter);

    final studentSections = vForStudentHomeList
        .map((vForStudentHome) =>
            StudentSection.fromVForStudentHome(vForStudentHome))
        .toList();
    for (var studentSection in studentSections) {
      log.info(studentSection.toString());
    }
    return studentSections;
  }
}
