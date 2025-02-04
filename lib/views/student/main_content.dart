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
    if (currentSection != null) {
      return _buildCurrentSection(context);
    } else if (upcomingSection != null) {
      return _buildUpcomingSection(context);
    } else {
      return _buildAllDone(context);
    }
  }

  Widget _buildCurrentSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SectionDetail(studentSection: currentSection!),
      ],
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Coming up...",
            style: theme.textTheme.titleLarge,
          ),
        ),
        SectionDetail(studentSection: upcomingSection!),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAllDone(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "All done for today!",
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
