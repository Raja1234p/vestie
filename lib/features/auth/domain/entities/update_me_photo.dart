/// How `PUT /users/me` should handle the multipart `file` field.
sealed class UpdateMePhoto {
  const UpdateMePhoto();
}

/// Omit `file` — name/username update only.
final class UpdateMePhotoUnchanged extends UpdateMePhoto {
  const UpdateMePhotoUnchanged();
}

/// Upload a new profile image.
final class UpdateMePhotoUpload extends UpdateMePhoto {
  final String filePath;

  const UpdateMePhotoUpload(this.filePath);
}

/// Legacy marker — use [DeleteMeProfilePictureUseCase] instead.
final class UpdateMePhotoRemove extends UpdateMePhoto {
  const UpdateMePhotoRemove();
}
