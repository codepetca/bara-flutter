import 'package:bara_flutter/models/student_section.dart';
import 'package:bara_flutter/views/student/section_detail.dart';
import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  final StudentSection? currentSection;
  final StudentSection? upcomingSection;

  const MainContent({this.currentSection, this.upcomingSection, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentSection != null) ...[
          SectionDetail(studentSection: currentSection!),
          SizedBox(height: 16),
        ] else if (upcomingSection != null) ...[
          Text(
            "Coming up...",
            style: TextStyle(fontSize: 24, color: Colors.grey),
          ),
          SectionDetail(studentSection: upcomingSection!),
          SizedBox(height: 16),
        ] else ...[
          Text(
            "All done for today!",
            style: TextStyle(fontSize: 24),
          ),
        ],
      ],
    );
  }
}
