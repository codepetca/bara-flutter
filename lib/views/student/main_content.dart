import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/views/student/section_detail.dart';
import 'package:flutter/material.dart';

class StudentMainContent extends StatelessWidget {
  final StudentSection? currentSection;
  final StudentSection? upcomingSection;

  const StudentMainContent(
      {this.currentSection, this.upcomingSection, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentSection != null) ...[
          SectionDetail(studentSection: currentSection!),
          SizedBox(height: 16),
        ] else if (upcomingSection != null) ...[
          Text(
            "Coming up...",
            style: theme.textTheme.titleLarge,
          ),
          SectionDetail(studentSection: upcomingSection!),
          SizedBox(height: 16),
        ] else ...[
          Text(
            "All done for today!",
            style: theme.textTheme.titleLarge,
          ),
        ],
      ],
    );
  }
}
