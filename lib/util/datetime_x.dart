import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  DateTime toToday() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  // Formats the date as an ISO 8601 string in the "yyyy-MM-dd" format.
  String toISO8601DateString() {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(this);
  }

  // Computed property for the date in "Jan 8, 2025" format
  String get formattedDate {
    final formatter = DateFormat.yMMMMd('en_US');
    return formatter.format(toLocal());
  }

  // Computed property for the time in "3:45 PM" format
  String get formattedTime {
    final formatter = DateFormat.jm();
    return formatter.format(toLocal());
  }

  // Computed property for the time in "3:45" format
  String get formattedTimeShort {
    final formatter = DateFormat('h:mm');
    return formatter.format(toLocal());
  }
}
