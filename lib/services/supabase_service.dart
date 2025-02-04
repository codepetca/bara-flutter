import 'package:bara_flutter/models/app_user.dart';
import 'package:bara_flutter/models/generated_classes.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/models/teacher_student.dart';
import 'package:bara_flutter/services/supabase_x.dart';
import 'package:bara_flutter/services/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends ChangeNotifier {
  final log = Logger('SupabaseService');

  bool _isLoading = true;
  List<StudentSection> _studentSections = [];
  List<TeacherStudent> _teacherStudents = [];
  DateTime _lastFetched =
      DateTime.fromMicrosecondsSinceEpoch(0); // Distant past

  late final TimerService _timerService = TimerService();
  DateTime _currentDate = DateTime.now(); // current data updated every tick

  // ------------------------------
  // Observable states
  // ------------------------------
  bool get isLoading => _isLoading;
  List<StudentSection> get studentSections => _studentSections;
  List<TeacherStudent> get teacherStudents => _teacherStudents;
  DateTime get lastFetched => _lastFetched;
  DateTime get currentDate => _currentDate;

  // If the last fetch was not today, then we need to refetch
  bool get requiresRefetch =>
      currentDate.year != lastFetched.year ||
      currentDate.month != lastFetched.month ||
      currentDate.day != lastFetched.day;

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

  void setCurrentDate(DateTime newDate) {
    _currentDate = newDate;
    notifyListeners();
  }

  void setLastFetched(DateTime newDate) {
    _lastFetched = newDate;
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
        await fetchStudentSections(appUser); // Fetch student sections
        // Start the minute timer
        _timerService.startMinuteTimer(
          onTick: () => setCurrentDate(DateTime.now()),
        );

      case ROLE_ENUM.teacher:
        await fetchTeacherStudents(appUser);
        // Start the hour timer
        _timerService.startHourTimer(
          onTick: () => setCurrentDate(DateTime.now()),
        );

      default:
        updateStudentSections([]);
        updateTeacherStudents([]);
        break;
    }
    setLoading(false);
  }

  /// -----------------------------------
  /// Student Methods
  /// -----------------------------------
  /// Fetch the sections for the student
  Future<void> fetchStudentSections(AppUser appUser) async {
    final studentId = appUser.profile.id;
    // Fetch the sections for the student
    final fetchedSections =
        await Supabase.instance.fetchStudentHomeData(studentId, currentDate);
    updateStudentSections(fetchedSections);
    setLastFetched(DateTime.now());
  }

  /// Sort the sections by start time
  List<StudentSection> get orderedStudentSectionsByStartTime {
    final sections = List<StudentSection>.from(_studentSections);
    sections.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sections;
  }

  /// Sort the sections by end time
  List<StudentSection> get orderedStudentSectionsByEndTime {
    final sections = List<StudentSection>.from(_studentSections);
    sections.sort((a, b) => a.endTime.compareTo(b.endTime));
    return sections;
  }

  /// Day is over
  bool get dayIsOver {
    if (_studentSections.isEmpty) return true;
    final lastSection = orderedStudentSectionsByEndTime.last;
    return currentDate.isAfter(lastSection.endTime);
  }

  /// Computed getter that returns the current section if one exists.
  StudentSection? get currentSection {
    if (_studentSections.isEmpty || dayIsOver) {
      return null;
    }
    final earlyEntryMinutes = Duration(minutes: 10);
    for (var section in orderedStudentSectionsByStartTime) {
      final startTimeWithEarlyEntry =
          section.startTime.subtract(earlyEntryMinutes);

      if (currentDate.isAfter(startTimeWithEarlyEntry) &&
          currentDate.isBefore(section.endTime)) {
        return section;
      }
    }
    return null;
  }

  /// Computed getter that returns the next upcoming section if one exists.
  StudentSection? get upcomingSection {
    // If there is a current section or no more sections for the day, return null
    if (currentSection != null || dayIsOver) {
      return null;
    }
    for (var section in orderedStudentSectionsByStartTime) {
      log.info(currentDate);
      log.info(section.startTime);
      if (currentDate.isBefore(section.startTime)) {
        return section;
      }
    }
    return null;
  }

  /// Scan is ready
  bool get scanIsReady {
    if (currentSection == null) return false;
    // If scan already submitted, return false
    if (currentSection!.scanSubmitted) return false;
    final currentSectionStartTime = currentSection!.startTime;
    final earlyEntryMinutes = Duration(minutes: 10);
    final startTimeWithEarlyEntry =
        currentSectionStartTime.subtract(earlyEntryMinutes);
    return currentDate.isAfter(startTimeWithEarlyEntry);
  }

  /// -----------------------------------
  /// Teacher Methods
  /// -----------------------------------
  /// Fetch the students for the teacher
  Future<void> fetchTeacherStudents(AppUser appUser) async {
    final fetchedTeacherStudents = await Supabase.instance.fetchTeacherHomeData(
      appUser.profile.id,
      currentDate,
    );
    updateTeacherStudents(fetchedTeacherStudents);
    setLastFetched(DateTime.now());
  }

  @override
  void dispose() {
    _timerService.stopTimers();
    super.dispose();
  }
}
