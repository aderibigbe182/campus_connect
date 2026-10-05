class ChatDateUtils {
  static String format(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday =
        today.subtract(const Duration(days: 1));

    final messageDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (messageDate == today) {
      return "Today";
    }

    if (messageDate == yesterday) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}/${date.year}";
  }
}