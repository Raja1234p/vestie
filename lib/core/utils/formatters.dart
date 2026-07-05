import 'package:intl/intl.dart';

/// Centralized formatting utility ensuring consistent output
class AppFormatters {
  AppFormatters._();

  /// Formats double explicitly into Currency string safely. E.g., "$1,234.56"
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final currencyFormatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return currencyFormatter.format(amount);
  }

  /// Grouped amount with cents, no symbol — for widgets that prepend `\$` themselves.
  static String formatMoneyAmount(double amount) {
    return NumberFormat('#,##0.00', 'en_US').format(amount);
  }

  /// Grouped whole amount without symbol. E.g. `1,000`
  static String formatWholeAmount(double amount) {
    return NumberFormat('#,##0', 'en_US').format(amount);
  }

  /// Format Date explicitly. "13 Apr 2026"
  static String formatDate(DateTime date) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    return dateFormatter.format(date);
  }

  /// Short date, no year — ledger/history rows. E.g. "Mar 12"
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Compact number formatter. E.g., 1.2k, 10M
  static String formatCompactNumber(num number) {
    return NumberFormat.compact().format(number);
  }
}
