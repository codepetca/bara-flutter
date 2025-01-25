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

  // Computed property for the date in "Tue Jan 8, 2025" format
  String get formattedDate {
    // final formatter = DateFormat.yMMMMd('en_US');
    final formatter = DateFormat('EEE MMM d, yyyy');
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

  /// Converts a time string (HH:mm) to Date object with the current date
  static DateTime? fromTimeString(String timeString) {
    // Ensure time string is of the format "HH:mm"
    if (timeString.length != 5) {
      print("Invalid time string format. Expected: HH:mm");
      return null;
    }
    // Add 00 seconds to the time string
    String timeStringWithSeconds = "$timeString:00";
    return fromTimeStringWithSeconds(timeStringWithSeconds);
  }

  /// Converts a time string (HH:mm:ss) to a DateTime object with the current date
  static DateTime? fromTimeStringWithSeconds(String timeString) {
    // Ensure time string is of the format "HH:mm:ss"
    if (timeString.length != 8) {
      print("Invalid time string format. Expected: HH:mm:ss");
      return null;
    }

    try {
      // Get the current date (without time)
      final DateTime now = DateTime.now();

      // Parse the time string
      final List<String> timeParts = timeString.split(':');
      if (timeParts.length != 3) {
        print("Invalid time string format. Expected: HH:mm:ss");
        return null;
      }

      // Extract hours, minutes, and seconds
      final int hours = int.parse(timeParts[0]);
      final int minutes = int.parse(timeParts[1]);
      final int seconds = int.parse(timeParts[2]);

      // Combine the current date with the time
      return DateTime(now.year, now.month, now.day, hours, minutes, seconds);
    } catch (e) {
      print("Error parsing time string: $e");
      return null;
    }
  }
}
