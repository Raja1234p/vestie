import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/invite_preview_entity.dart';
import '../repositories/project_repository.dart';

class PreviewInviteUseCase {
  final ProjectRepository repository;

  PreviewInviteUseCase(this.repository);

  Future<Either<Failure, InvitePreviewEntity>> call(String inviteCode) async {
    return repository.previewInvite(inviteCode);
  }
}

