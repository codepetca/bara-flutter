import 'package:bara_flutter/main.dart';
import 'package:bara_flutter/services/supabase_service.dart';
import 'package:bara_flutter/util/datetime_x.dart';
import 'package:bara_flutter/views/student/student_scan_button.dart';
import 'package:bara_flutter/views/student/main_content.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:watch_it/watch_it.dart';

class StudentHome extends WatchingWidget {
  final log = Logger('StudentHome');
  StudentHome({super.key});

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
              onPressed: _startNFCReading,
              scanReady: scanIsReady,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Start NFC reading
  void _startNFCReading() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      log.warning('NFC is not available');
      return;
    }
    log.info('Starting NFC reading...');
    NfcManager.instance.startSession(
      alertMessage: 'Hold the top of your device near the NFC tag',
      onDiscovered: (NfcTag tag) async {
        log.info('NFC tag discovered: ${tag.data}');
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) {
          log.warning('Tag is not NDEF');
          return;
        }

        log.info('NDEF message: ${ndef.additionalData}}');
        log.info('Stopping NFC reading...');
        NfcManager.instance.stopSession();
      },
    );
  }
}
