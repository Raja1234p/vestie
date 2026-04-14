import '../utils/formatters.dart';

extension DateTimeExtensions on DateTime {
  String get toFormattedDate {
    return AppFormatters.formatDate(this);
  }

  /// Format specifically required for backend API payload
  String get toApiFormat {
    return toIso8601String();
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
