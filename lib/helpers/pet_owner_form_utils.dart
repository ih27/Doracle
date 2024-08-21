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
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

TimeOfDay parseTimeString(String timeString) {
  List<String> parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
