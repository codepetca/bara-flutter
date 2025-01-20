import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

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
            child: Text(
                'If you are having issues signing in, you can try tapping the following.'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: onResetSavedData,
              child: Text('Reset saved data',
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.colorScheme.secondary)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: onSignOut,
              child: Text(
                'Sign Out',
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.colorScheme.secondary),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  // TODO: Reset saved data
  void onResetSavedData() {
    log.warning('onResetSavedData not implemented');
  }

  // TODO: Sign out
  void onSignOut() {
    log.warning('OnSignOut not implemented');
  }
}
