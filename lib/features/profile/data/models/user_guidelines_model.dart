import '../../domain/entities/user_guideline.dart';
import '../../domain/entities/user_guidelines_page.dart';

class UserGuidelinesModel extends UserGuidelinesPage {
  const UserGuidelinesModel({
    required super.pageTitle,
    required super.guidelines,
  });

  factory UserGuidelinesModel.fromJson(Map<String, dynamic> json) {
    final raw = json['guidelines'];
    final items = <UserGuideline>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is! Map) continue;
        final map = Map<String, dynamic>.from(entry);
        final title = map['title']?.toString().trim() ?? '';
        final description = map['description']?.toString().trim() ?? '';
        if (title.isEmpty && description.isEmpty) continue;
        items.add(UserGuideline(title: title, description: description));
      }
    }

    return UserGuidelinesModel(
      pageTitle: json['pageTitle']?.toString().trim() ?? '',
      guidelines: items,
    );
  }
}
