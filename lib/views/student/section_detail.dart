import 'package:bara_flutter/util/datetime_x.dart';
import 'package:flutter/material.dart';
import 'package:bara_flutter/models/student_section.dart';

class SectionDetail extends StatelessWidget {
  final StudentSection studentSection;

  const SectionDetail({required this.studentSection, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          studentSection.block,
          style: theme.textTheme.headlineMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          studentSection.sectionCode,
          style: theme.textTheme.headlineMedium,
        ),
        SizedBox(height: 8),
        Text(
          'Start ${studentSection.startTime.formattedTimeShort}',
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          'End ${studentSection.endTime.formattedTimeShort}',
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: 8),
        studentSection.scanSubmitted
            ? Icon(
                Icons.check_outlined,
                color: Colors.green,
                size: 40,
              )
            : Opacity(
                opacity: 0.5,
                child: Icon(
                  Icons.close_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
      ],
    );
  }
}
