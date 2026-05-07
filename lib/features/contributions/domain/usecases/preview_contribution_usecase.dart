import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/contribution_preview_entity.dart';
import '../../domain/repositories/contribution_repository.dart';

class PreviewContributionUseCase {
  final ContributionRepository repository;

  PreviewContributionUseCase(this.repository);

  Future<Either<Failure, ContributionPreviewEntity>> call(PreviewContributionParams params) async {
    return await repository.previewContribution(params.projectId, params.amount);
  }
}

class PreviewContributionParams extends Equatable {
  final String projectId;
  final double amount;

  const PreviewContributionParams({required this.projectId, required this.amount});

  @override
  List<Object?> get props => [projectId, amount];
}
