import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _mediumFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortFormat = DateFormat('MMM dd');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  static String formatMedium(DateTime date) {
    return _mediumFormat.format(date);
  }

  static String formatShort(DateTime date) {
    return _shortFormat.format(date);
  }

  static String toIso(DateTime date) {
    return _isoFormat.format(date);
  }

  static DateTime parseIso(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return DateTime.now();
    }
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
}
