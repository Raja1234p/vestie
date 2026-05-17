import 'package:vestie/core/constants/app_strings.dart';

/// Human-readable deadline for project cards (Home / Discover).
///
/// [endsInIsoUtc] is an ISO-8601 instant (e.g. API `endsAtUtc`), stored in [Project.endsIn].
class ProjectEndRelativeLabel {
  ProjectEndRelativeLabel._();

  /// Calendar date of [d] in UTC (strip time).
  static DateTime _dateOnlyUtc(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day);

  /// Adds one calendar month to [d] (UTC date-only), clamping the day.
  static DateTime _addOneMonthUtc(DateTime d) {
    var y = d.year;
    var m = d.month + 1;
    if (m > 12) {
      m = 1;
      y++;
    }
    final last = DateTime.utc(y, m + 1, 0).day;
    final day = d.day.clamp(1, last);
    return DateTime.utc(y, m, day);
  }

  /// When less than 24h remain: `5h 30m`, or `45m` if under an hour.
  static String _hoursMinutesFrom(Duration remaining) {
    if (remaining <= Duration.zero) {
      return AppStrings.projectEndEnded;
    }
    final totalMinutes = remaining.inMinutes;
    if (totalMinutes < 1) {
      return AppStrings.projectEndLessThanOneMinute;
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) {
      return '${minutes}m';
    }
    return '${hours}h ${minutes}m';
  }

  /// True when the list/card should show the "Ends in …" row.
  static bool hasDisplayableEnd(String? endsInIsoUtc) =>
      emphasis(endsInIsoUtc).isNotEmpty;

  /// Bold segment after "Ends in " (or full phrase for ended).
  static String emphasis(String? endsInIsoUtc) {
    if (endsInIsoUtc == null || endsInIsoUtc.trim().isEmpty) {
      return '';
    }
    final raw = endsInIsoUtc.trim();
    final end = DateTime.tryParse(raw);
    if (end == null) {
      return raw.isEmpty ? '' : raw;
    }

    final endUtc = end.isUtc ? end : end.toUtc();
    final now = DateTime.now().toUtc();

    if (!endUtc.isAfter(now)) {
      return AppStrings.projectEndEnded;
    }

    final remaining = endUtc.difference(now);
    if (remaining < const Duration(hours: 24)) {
      return _hoursMinutesFrom(remaining);
    }

    final endDay = _dateOnlyUtc(endUtc);
    final nowDay = _dateOnlyUtc(now);

    var cursor = nowDay;
    var months = 0;
    const maxMonths = 1200;
    while (months < maxMonths) {
      final next = _addOneMonthUtc(cursor);
      if (next.isAfter(endDay)) break;
      cursor = next;
      months++;
    }
    final days = endDay.difference(cursor).inDays;

    if (months == 0) {
      if (days <= 0) {
        return _hoursMinutesFrom(remaining);
      }
      return AppStrings.projectEndDaysOnly(days);
    }

    if (days <= 0) {
      return AppStrings.projectEndMonthsOnly(months);
    }
    if (months == 1 && days == 1) {
      return AppStrings.projectEndOneMonthOneDay;
    }
    if (months == 1) {
      return AppStrings.projectEndOneMonthDays(days);
    }
    if (days == 1) {
      return AppStrings.projectEndMonthsOneDay(months);
    }
    return AppStrings.projectEndMonthsDays(months, days);
  }

  /// When true, [emphasis] is a full sentence — omit the "Ends in " prefix in the row.
  static bool isFullSentence(String? endsInIsoUtc) {
    if (endsInIsoUtc == null || endsInIsoUtc.trim().isEmpty) return false;
    final raw = endsInIsoUtc.trim();
    final end = DateTime.tryParse(raw);
    if (end == null) return false;
    final endUtc = end.isUtc ? end : end.toUtc();
    final now = DateTime.now().toUtc();
    return !endUtc.isAfter(now);
  }
}
