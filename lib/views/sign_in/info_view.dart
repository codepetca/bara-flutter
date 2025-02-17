import 'package:bara_flutter/models/local_store.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:watch_it/watch_it.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoView extends StatelessWidget {
  final log = Logger('InfoView');

  InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Bara', style: theme.textTheme.displaySmall),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Attendance simplified.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed: onResetSavedData,
              child: Text('Reset saved data'),
            ),
          ),
          Spacer(),
          _buildFooter(context),
        ],
      ),
    );
  }

  // TODO: Reset saved data
  void onResetSavedData() async {
    log.info('Clearing saved data');
    di<LocalStore>().clear();
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: launchPrivacy,
          child: Text(
            'Privacy',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            ),
          ),
        ),
        const Text('\t | \t'),
        InkWell(
          onTap: launchTerms,
          child: Text(
            'Terms',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            ),
          ),
        ),
      ],
    );
  }

  // Launch URLs
  Future<void> launchPrivacy() async =>
      launchSite('https://codepet.ca/#/privacy-page');

  Future<void> launchTerms() async =>
      launchSite('https://codepet.ca/#/terms-page');

  /// Launch a URL
  Future<void> launchSite(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      log.warning('Could not launch $url');
    }
  }
}
