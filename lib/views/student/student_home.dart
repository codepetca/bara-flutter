import 'dart:typed_data';

import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/services/supabase_auth.dart';
import 'package:bara_flutter/services/supabase_service.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:bara_flutter/views/student/student_scan_button.dart';
import 'package:bara_flutter/views/student/main_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_it/watch_it.dart';
import 'package:bara_flutter/services/supabase_x.dart';

class StudentHome extends WatchingStatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final log = Logger('StudentHome');

  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentService = watchIt<SupabaseService>();
    final currentSection = studentService.currentSection;
    final upcomingSection = studentService.upcomingSection;
    final scanIsReady = studentService.scanIsReady;
    final currentDate = studentService.currentDate;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, Routes.profile),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date
            Text(
              currentDate.formattedDate,
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
              onPressed: () => _startNFCReading(context),
              scanReady: scanIsReady,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Show NFC scan modal when scanning
  void showScanModal(BuildContext context) {
    // Show bottom sheet modal
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allow users to cancel
      enableDrag: false, // Prevent accidental dismiss
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Hold your phone near the NFC tag',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  // Show NFC scan dialog when scanning
  void showScanDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allow users to dismiss the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scanning NFC Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Hold your phone near the NFC tag',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Dismiss the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Start NFC reading
  void _startNFCReading(BuildContext context) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      log.warning('NFC is not available');
      return;
    }

    setState(() => _isScanning = true);
    // showScanModal(context);

    log.info('Starting NFC reading...');
    NfcManager.instance.startSession(
      alertMessage: 'Hold the top of your device near the NFC tag',
      onDiscovered: (NfcTag tag) async {
        log.info('NFC tag discovered: ${tag.data}');

        Uint8List? identifier;
        // Try getting the identifier from nfca (Android)
        if (tag.data.containsKey('nfca')) {
          identifier = tag.data['nfca']['identifier'];
        }

        // Try getting the identifier from ndef (iOS)
        if (identifier == null && tag.data.containsKey('ndef')) {
          identifier = tag.data['ndef']['identifier'];
        }

        // Convert identifier (if found) to a hex string
        if (identifier != null) {
          final serialNumber = identifier
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join('')
              .toUpperCase(); // Format like 04576490780000

          final scanTime = DateTime.now(); // Get the time of scan
          final studentNumber =
              di<SupabaseAuth>().appUser?.profile.studentNumber ?? '';
          // Send the scan
          log.info(
              'TagUid: $serialNumber, StudentNumber: $studentNumber, ScanTime: $scanTime');
          final sendSuccess = await Supabase.instance.sendAttendanceScan(
            tagUid: serialNumber,
            studentNumber: studentNumber,
            scanTime: scanTime,
          );

          if (sendSuccess) {
            log.info('Attendance scan sent successfully.');
            // Refetch student sections
            di<SupabaseService>().fetchStudentSections(
              di<SupabaseAuth>().appUser!,
            );
            // Update local scan status
            // di<SupabaseService>().updateCurrentSectionEntryTime(scanTime);
          } else {
            log.warning('Failed to send scan.');
          }
        } else {
          log.warning('Could not extract tag serial number.');
        }

        // log.info('Stopping NFC reading...');
        // NfcManager.instance.stopSession();
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }
}
