import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/utils/project_gallery_image_urls.dart';
import 'package:vestie/features/projects/domain/entities/project_image_entity.dart';

void main() {
  group('ProjectGalleryImageUrls', () {
    const cover =
        'https://cdn.example.com/cover.jpg';
    const second =
        'https://cdn.example.com/two.jpg';

    test('uses sorted images when gallery is present', () {
      final urls = ProjectGalleryImageUrls.resolve(
        coverImageUrl: cover,
        images: const [
          ProjectImageEntity(
            id: '2',
            imageUrl: second,
            sortOrder: 1,
          ),
          ProjectImageEntity(
            id: '1',
            imageUrl: cover,
            sortOrder: 0,
          ),
        ],
      );

      expect(urls, [cover, second]);
    });

    test('falls back to cover when images are empty', () {
      expect(
        ProjectGalleryImageUrls.resolve(coverImageUrl: cover),
        [cover],
      );
    });

    test('initialIndex matches cover url', () {
      final urls = [cover, second];
      expect(
        ProjectGalleryImageUrls.initialIndex(urls, second),
        1,
      );
    });
  });
}
