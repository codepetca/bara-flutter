import 'package:bara_flutter/models/generated_classes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension SupabaseX on Supabase {
  Future<void> fetchTeachers() async {
    print('Fetching teachers...');

    final teachers =
        await client.teacher.select().withConverter(Teacher.converter);
    print(teachers.map((teacher) => teacher.toJson()).toList());
  }
}
