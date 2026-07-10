class ProofDateUtils {
  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String dateKey(DateTime value) {
    final date = dateOnly(value);
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? tryParseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return null;
    }

    return dateOnly(parsed);
  }

  static bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String friendlyDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[value.month - 1];
    return '$month ${value.day}, ${value.year}';
  }

  static String todayLabel() {
    return friendlyDate(DateTime.now());
  }

  static int? minutesFromTimeString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return (hour * 60) + minute;
  }

  static int minutesBetween(String? startTime, String? endTime) {
    final start = minutesFromTimeString(startTime);
    final end = minutesFromTimeString(endTime);
    if (start == null || end == null || end <= start) {
      return 0;
    }

    return end - start;
  }

  static String formatTimeLabel(String? value) {
    final totalMinutes = minutesFromTimeString(value);
    if (totalMinutes == null) {
      return '';
    }

    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');

    return '$displayHour:$displayMinute $suffix';
  }

  static String formatTimeRange(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) {
      return '';
    }

    final start = formatTimeLabel(startTime);
    final end = formatTimeLabel(endTime);
    if (start.isEmpty || end.isEmpty) {
      return '';
    }

    return '$start - $end';
  }
}
