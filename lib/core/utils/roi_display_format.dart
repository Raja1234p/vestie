/// True when ROI should appear in list/detail UI (non-null and > 0).
bool isDisplayableRoi(double? roiPercentage) {
  if (roiPercentage == null) return false;
  return roiPercentage > 0;
}

/// Normalizes API ROI for domain models — null and `<= 0` become null.
double? normalizeDisplayableRoi(double? roiPercentage) {
  if (!isDisplayableRoi(roiPercentage)) return null;
  return roiPercentage;
}

/// Formats API `roiPercentage` for list/detail rows (e.g. `2.5%`).
String formatRoiPercentDisplay(double? roiPercentage) {
  if (!isDisplayableRoi(roiPercentage)) return '';
  final v = roiPercentage!;
  if (v == v.roundToDouble()) return '${v.round()}%';
  final oneDecimal = (v * 10).round() / 10;
  if (oneDecimal == oneDecimal.roundToDouble()) {
    return '${oneDecimal.round()}%';
  }
  return '${oneDecimal.toStringAsFixed(1)}%';
}
