import 'package:bara_flutter/models/generated_classes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

extension SupabaseX on Supabase {
  Future<void> fetchTeachers() async {
    print('Fetching teachers...');

    final teachers =
        await client.teacher.select().withConverter(Teacher.converter);
    print(teachers.map((teacher) => teacher.toJson()).toList());
  }

  Future<void> fetchStudentHomeData(String studentId, String date) async {
    final studentSections = await client.v_for_student_home
        .select()
        .eq("student_id", studentId)
        .eq("date", date)
        .limit(20)
        .withConverter(VForStudentHome.converter);

    print(studentSections.map((section) => section.toJson()).toList());
  }
}
