import 'package:bara_flutter/util/datetime_x.dart';
import 'package:flutter/material.dart';
import 'package:bara_flutter/models/student_section.dart';

class SectionDetail extends StatelessWidget {
  final StudentSection studentSection;

  const SectionDetail({required this.studentSection, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          studentSection.sectionCode,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'Start ${studentSection.startTime.formattedTimeShort}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'End ${studentSection.endTime.formattedTimeShort}',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
