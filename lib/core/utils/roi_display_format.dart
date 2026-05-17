/// Formats API `roiPercentage` for list/detail rows (e.g. `2.5%`).
String formatRoiPercentDisplay(double? roiPercentage) {
  if (roiPercentage == null) return '';
  final v = roiPercentage;
  if (v == v.roundToDouble()) return '${v.round()}%';
  final oneDecimal = (v * 10).round() / 10;
  if (oneDecimal == oneDecimal.roundToDouble()) {
    return '${oneDecimal.round()}%';
  }
  return '${oneDecimal.toStringAsFixed(1)}%';
}
