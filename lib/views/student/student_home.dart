import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/services/timer_service.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:bara_flutter/views/student/student_scan_button.dart';
import 'package:bara_flutter/views/student/main_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bara_flutter/services/supabase_x.dart';
import 'package:watch_it/watch_it.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final log = Logger('StudentHome');

  final _timer = di.get<TimerService>();
  List<StudentSection> sections = [];
  StudentSection? currentSection;
  StudentSection? upcomingSection;

  @override
  void initState() {
    super.initState();
    // Fetch student data
    _onFetchStudentData();
    // Update current section
    _timer.startTimer(onTick: _updateCurrentSection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date
            Text(
              DateTime.now().formattedDate,
              style: theme.textTheme.titleLarge,
            ),
            Spacer(),
            StudentMainContent(
              currentSection: currentSection,
              upcomingSection: upcomingSection,
            ),
            Spacer(),
            // Scan button
            StudentScanButton(
              onPressed: _startNFCReading,
              scanReady: scanReady,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // True if scan is ready
  bool get scanReady {
    if (currentSection == null) return false;
    return !currentSection!.scanSubmitted;
  }

  void _startNFCReading() {
    throw UnimplementedError();
  }

  // TODO: Use actual student ID and date
  // save fetched data to shared preferences
  Future<void> _onFetchStudentData() async {
    log.info('Fetching student data...');
    final studentId = '56ad7055-3d70-4b53-8e4f-8d24832a285f';
    final date = '2025-01-10';
    final fetchedSections =
        await Supabase.instance.fetchStudentHomeData(studentId, date);
    setState(() {
      sections = fetchedSections;
      _updateCurrentSection();
    });
  }

  void _updateCurrentSection() {
    log.info("Updating current section...");

    final currentDate = DateTime.now();
    if (sections.isEmpty) {
      log.info("No sections found for today");
      setState(() {
        upcomingSection = null;
        currentSection = null;
      });
      return;
    }

    final orderedSectionsByStartTime = sections
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final orderedSectionsByEndTime = sections
      ..sort((a, b) => a.endTime.compareTo(b.endTime));

    for (var section in orderedSectionsByStartTime) {
      final earlyEntrySeconds = Duration(minutes: 10);
      final startTimeWithEarlyEntry =
          section.startTime.subtract(earlyEntrySeconds);

      if (currentDate.isAfter(startTimeWithEarlyEntry) &&
          currentDate.isBefore(section.endTime)) {
        setState(() {
          currentSection = section;
          upcomingSection = null;
        });
        return;
      }
    }

    if (currentDate.isAfter(orderedSectionsByEndTime.last.endTime)) {
      setState(() {
        currentSection = null;
        upcomingSection = null;
      });
      return;
    }

    for (var section in orderedSectionsByStartTime) {
      if (currentDate.isBefore(section.startTime)) {
        setState(() {
          currentSection = null;
          upcomingSection = section;
        });
        return;
      }
    }

    log.info("Logic error in StudentHomeView _updateCurrentSection()");
  }
}
