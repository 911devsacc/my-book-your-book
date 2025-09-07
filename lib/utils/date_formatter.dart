import 'package:cloud_firestore/cloud_firestore.dart';

class DateFormatter {
  static String formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      // If more than a week ago, show date
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      // If within a week, show days ago
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      // If within a day, show hours ago
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      // If within an hour, show minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // If less than a minute ago
      return 'Just now';
    }
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
