String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

DateTime parseDateString(String dateString) {
  List<String> parts = dateString.split('/');
  return DateTime(
      int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}
