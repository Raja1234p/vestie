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

  /// Bold segment after "Ends in " (or full phrase for today / ended).
  static String emphasis(String? endsInIsoUtc) {
    if (endsInIsoUtc == null || endsInIsoUtc.trim().isEmpty) {
      return '';
    }
    final raw = endsInIsoUtc.trim();
    final end = DateTime.tryParse(raw);
    if (end == null) {
      return raw.isEmpty ? '' : raw;
    }

    final now = DateTime.now().toUtc();
    final endDay = _dateOnlyUtc(end);
    final nowDay = _dateOnlyUtc(now);

    if (endDay.isBefore(nowDay)) {
      return AppStrings.projectEndEnded;
    }
    if (endDay == nowDay) {
      return AppStrings.projectEndToday;
    }

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
        return AppStrings.projectEndLessThanOneDay;
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
    final endDay = _dateOnlyUtc(end);
    final nowDay = _dateOnlyUtc(DateTime.now().toUtc());
    return endDay.isBefore(nowDay) || endDay == nowDay;
  }
}
