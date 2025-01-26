import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/services/timer_service.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:bara_flutter/views/student/student_scan_button.dart';
import 'package:bara_flutter/views/student/main_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nfc_manager/nfc_manager.dart';
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
    // Update current section on timer tick every minute
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

  // Start NFC reading
  void _startNFCReading() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      log.warning('NFC is not available');
      return;
    }
    NfcManager.instance.startSession(
      alertMessage: 'Hold the top of your device near the NFC tag',
      onDiscovered: (NfcTag tag) async {
        log.info('NFC tag discovered: ${tag.data}');
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) {
          log.warning('Tag is not NDEF');
          return;
        }

        log.info('NDEF message: ${ndef.read()}');
      },
    );
    NfcManager.instance.stopSession();
  }

  // TODO: Use actual student ID and date
  // save fetched data to shared preferences
  Future<void> _onFetchStudentData() async {
    log.info('Fetching student data...');
    // final studentId = '56ad7055-3d70-4b53-8e4f-8d24832a285f';
    // final date = '2025-01-10';
    final appUser = di<SupabaseAuth>().appUser;
    if (appUser == null) {
      log.warning('App user is null');
      return;
    }
    final studentId = appUser.profile.id;
    final date = DateTime.now().formattedDate;
    log.info('Student ID: $studentId, Date: $date');
    final fetchedSections =
        await Supabase.instance.fetchStudentHomeData(studentId, date);
    if (mounted) {
      setState(() {
        sections = fetchedSections;
        _updateCurrentSection();
      });
    }
  }

  // Update current section based on current time
  void _updateCurrentSection() {
    log.info("Updating current section...");

    // If there are no sections, set current and upcoming to null
    if (sections.isEmpty) {
      log.info("No sections found for today");
      if (mounted) {
        setState(() {
          upcomingSection = null;
          currentSection = null;
        });
      }
      return;
    }

    // Get the current datetime
    final currentDate = DateTime.now();

    // Sort sections by start and end time
    final orderedSectionsByStartTime = sections
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final orderedSectionsByEndTime = sections
      ..sort((a, b) => a.endTime.compareTo(b.endTime));

    // Set the current section if it exists
    final earlyEntryMinutes = Duration(minutes: 10);
    for (var section in orderedSectionsByStartTime) {
      final startTimeWithEarlyEntry =
          section.startTime.subtract(earlyEntryMinutes);

      if (currentDate.isAfter(startTimeWithEarlyEntry) &&
          currentDate.isBefore(section.endTime)) {
        setState(() {
          currentSection = section;
          upcomingSection = null;
        });
        return;
      }
    }

    // If the current time is after the last section, set current and upcoming to null
    if (currentDate.isAfter(orderedSectionsByEndTime.last.endTime)) {
      log.info(
          "Last section has ended ${orderedSectionsByEndTime.last.endTime}");
      if (mounted) {
        setState(() {
          currentSection = null;
          upcomingSection = null;
        });
      }
      return;
    }

    // Set the upcoming section if it exists
    for (var section in orderedSectionsByStartTime) {
      log.info("Upcoming section: $section");
      if (currentDate.isBefore(section.startTime)) {
        if (mounted) {
          setState(() {
            currentSection = null;
            upcomingSection = section;
          });
        }
        return;
      }
    }

    // This should never be reached
    log.severe(
        "This line should not be reached. Logic error in StudentHomeView _updateCurrentSection()");
  }
}
