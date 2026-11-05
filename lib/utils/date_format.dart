// Pure date/time formatting helpers.

String relativeTime(DateTime dateTime, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(dateTime);
  if (diff.isNegative || diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 30) {
    final weeks = diff.inDays ~/ 7;
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 365) {
    final months = diff.inDays ~/ 30;
    return '$months month${months == 1 ? '' : 's'} ago';
  }
  final years = diff.inDays ~/ 365;
  return '$years year${years == 1 ? '' : 's'} ago';
}

String monthYear(DateTime dateTime) {
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
  return '${months[dateTime.month - 1]} ${dateTime.year}';
}
