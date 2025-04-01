import 'package:flutter/material.dart';

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

DateTime parseDateString(String dateString) {
  List<String> parts = dateString.split('/');
  return DateTime(
      int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}

String formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

TimeOfDay parseTimeString(String timeString) {
  final parts = timeString.split(' ');
  final timeParts = parts[0].split(':');
  int hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);

  if (parts.length > 1) {
    final period = parts[1];
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }
  }

  return TimeOfDay(hour: hour, minute: minute);
}
