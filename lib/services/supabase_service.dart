import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/models/teacher_student.dart';
import 'package:bara_flutter/services/supabase_x.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends ChangeNotifier {
  final log = Logger('SupabaseService');

  bool _isLoading = true;
  List<StudentSection> _studentSections = [];
  List<TeacherStudent> _teacherStudents = [];

  // ------------------------------
  // Listenable states
  // ------------------------------
  bool get isLoading => _isLoading;
  List<StudentSection> get studentSections => _studentSections;
  List<TeacherStudent> get teacherStudents => _teacherStudents;

  DateTime lastFetched = DateTime.fromMicrosecondsSinceEpoch(0); // Distant past

  // If the last fetch was not today, then we need to refetch
  bool get requiresRefetch => !DateTime.now().isAtSameMomentAs(
      DateTime(lastFetched.year, lastFetched.month, lastFetched.day));

  // ------------------------------
  // Setters for listenable states
  // ------------------------------
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void updateStudentSections(List<StudentSection> newSections) {
    _studentSections = newSections;
    notifyListeners();
  }

  void updateTeacherStudents(List<TeacherStudent> newStudents) {
    _teacherStudents = newStudents;
    notifyListeners();
  }

  // ------------------------------
  // Methods
  // ------------------------------

  /// Call after authentication and before presenting app view
  Future<void> startAppSession(AppUser appUser) async {
    log.info('Starting app session for user: ${appUser.profile.email}');
    switch (appUser.profile.role) {
      case ROLE_ENUM.student:
        await fetchStudentSections(appUser);
      case ROLE_ENUM.teacher:
        await fetchTeacherStudents(appUser);
      default:
        updateStudentSections([]);
        updateTeacherStudents([]);
        break;
    }
    setLoading(false);
  }

  /// Fetch the sections for the student
  Future<void> fetchStudentSections(AppUser appUser) async {
    final studentId = appUser.profile.id;
    final today = DateTime.now();
    // Fetch the sections for the student
    final fetchedSections =
        await Supabase.instance.fetchStudentHomeData(studentId, today);
    updateStudentSections(fetchedSections);
    lastFetched = today;
  }

  /// Fetch the students for the teacher
  Future<void> fetchTeacherStudents(AppUser appUser) async {
    final today = DateTime.now();
    final fetchedTeacherStudents = await Supabase.instance.fetchTeacherHomeData(
      appUser.profile.id,
      DateTime.now(),
    );
    updateTeacherStudents(fetchedTeacherStudents);
    lastFetched = today;
  }
}
