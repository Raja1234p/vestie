import '../../../../core/utils/safe_parser.dart';
import '../../domain/entities/project_image_entity.dart';

class ProjectImageModel extends ProjectImageEntity {
  const ProjectImageModel({
    required super.id,
    required super.imageUrl,
    super.sortOrder = 0,
  });

  factory ProjectImageModel.fromJson(Map<String, dynamic> json) {
    return ProjectImageModel(
      id: json.safeString('id'),
      imageUrl: json.safeString('imageUrl'),
      sortOrder: json.safeInt('sortOrder'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'sortOrder': sortOrder,
  };

  static List<ProjectImageModel> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final images = raw
        .whereType<Map>()
        .map(
          (item) => ProjectImageModel.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((image) => image.id.isNotEmpty && image.imageUrl.isNotEmpty)
        .toList(growable: false);
    if (images.length < 2) return images;
    final sorted = [...images]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }
}
