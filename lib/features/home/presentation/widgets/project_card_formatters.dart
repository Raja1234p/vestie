import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/project.dart';

String formatProjectWhole(double? value) {
  final raw = (value ?? 0).toStringAsFixed(0);
  final parts = raw.split('');
  final buf = StringBuffer();
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
    buf.write(parts[i]);
  }
  return buf.toString();
}

String projectRaisedText(Project project) {
  final amount = formatProjectWhole(project.currentAmount);
  final prefix = project.relation == ProjectRelation.owned
      ? AppStrings.labelRaised
      : AppStrings.labelTotal;
  return '$prefix \$$amount';
}
