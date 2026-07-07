/// Project image upload rules for the create wizard.
abstract final class CreateProjectImageLimits {
  CreateProjectImageLimits._();

  static const int maxImages = 5;
  static const int maxBytesPerFile = 5 * 1024 * 1024;

  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
  ];

  /// API multipart field name — repeat for each file (0–5).
  static const String multipartFieldName = 'images';
}
