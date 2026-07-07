import 'package:vestie/core/widgets/common/app_network_image.dart';
import 'package:vestie/features/projects/domain/entities/project_image_entity.dart';

/// Resolves gallery URLs for the project images viewer.
abstract final class ProjectGalleryImageUrls {
  ProjectGalleryImageUrls._();

  static List<String> resolve({
    String? coverImageUrl,
    List<ProjectImageEntity> images = const [],
  }) {
    final urls = <String>[];

    if (images.isNotEmpty) {
      final sorted = [...images]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      for (final image in sorted) {
        _addUnique(urls, image.imageUrl);
      }
      return urls;
    }

    _addUnique(urls, coverImageUrl);
    return urls;
  }

  static int initialIndex(List<String> urls, String? coverImageUrl) {
    final cover = coverImageUrl?.trim();
    if (cover == null || cover.isEmpty) return 0;
    final index = urls.indexOf(cover);
    return index >= 0 ? index : 0;
  }

  static void _addUnique(List<String> urls, String? raw) {
    final url = raw?.trim() ?? '';
    if (!AppNetworkImage.isValidNetworkUrl(url)) return;
    if (urls.contains(url)) return;
    urls.add(url);
  }
}
