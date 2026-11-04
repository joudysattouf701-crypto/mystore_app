class AppDate {
  // تاريخ بالتوقيت المحلي: 3/11/2026
  static String format(DateTime date) {
    final DateTime local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  // تاريخ ووقت بالتوقيت المحلي: 3/11/2026 - 14:05
  static String formatWithTime(DateTime date) {
    final DateTime local = date.toLocal();
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '${format(local)} - $hour:$minute';
  }
}
