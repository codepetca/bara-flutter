import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

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
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allow dismissal by tapping outside
      backgroundColor: Colors.transparent, // Makes blur effect visible
      barrierColor: Colors.black.withValues(
          alpha: 0.2, red: 0, green: 0, blue: 0), // Subtle dimming effect
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(alpha: 0.6, red: 0, green: 0, blue: 0),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hold the top of your phone near the tag.',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
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
    showScanModal(context);
    // showDialog(context: context, builder: (context) => _NfcScanningDialog());

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

// Scan dialog
class _NfcScanningDialog extends StatefulWidget {
  @override
  _NfcScanningDialogState createState() => _NfcScanningDialogState();
}

class _NfcScanningDialogState extends State<_NfcScanningDialog> {
  int _gradientIndex = 0;
  late Timer _timer;

  final List<List<Color>> _gradients = [
    [Colors.blue, Colors.purple],
    [Colors.purple, Colors.red],
    [Colors.red, Colors.orange],
    [Colors.orange, Colors.blue],
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _gradientIndex = (_gradientIndex + 1) % _gradients.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradients[_gradientIndex],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Scanning for NFC Tag...",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Hold your device near the tag",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
