/// Relative labels for notification [createdAtUtc] (e.g. "3 min ago").
abstract final class NotificationTimeFormatter {
  NotificationTimeFormatter._();

  static DateTime? parseCreatedAtUtc(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    return parsed.toUtc();
  }

  static String format(DateTime? createdAtUtc) {
    if (createdAtUtc == null) return '';

    final then = createdAtUtc.toLocal();
    final now = DateTime.now();
    var diff = now.difference(then);
    if (diff.isNegative) diff = Duration.zero;

    final minutes = diff.inMinutes;
    if (minutes < 1) return 'Just now';
    if (minutes < 60) {
      return minutes == 1 ? '1 min ago' : '$minutes min ago';
    }

    final hours = diff.inHours;
    if (hours < 24) {
      return hours == 1 ? '1 hr ago' : '$hours hr ago';
    }

    final calendarDays = _calendarDaysBetween(then, now);
    if (calendarDays == 1) return 'Yesterday';
    if (calendarDays < 7) {
      return calendarDays == 1 ? '1 day ago' : '$calendarDays days ago';
    }

    final weeks = calendarDays ~/ 7;
    if (weeks < 5) {
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }

    final months = calendarDays ~/ 30;
    if (months < 12) {
      return months <= 1 ? '1 month ago' : '$months months ago';
    }

    final years = calendarDays ~/ 365;
    return years <= 1 ? '1 year ago' : '$years years ago';
  }

  static int _calendarDaysBetween(DateTime earlier, DateTime later) {
    final start = DateTime(earlier.year, earlier.month, earlier.day);
    final end = DateTime(later.year, later.month, later.day);
    return end.difference(start).inDays;
  }
}
