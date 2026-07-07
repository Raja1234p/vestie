/// `POST /projects/{id}/announcements` multipart attachment rules.
abstract final class AnnouncementAttachmentLimits {
  AnnouncementAttachmentLimits._();

  static const int maxHeadingLength = 200;
  static const int maxContentLength = 1000;
  static const int maxBytesPerFile = 5 * 1024 * 1024;

  /// Repeatable multipart field name per API contract.
  static const String multipartFieldName = 'attachments';

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
}
