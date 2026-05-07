import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_summary_entity.dart';
import '../entities/project_detail_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<ProjectSummaryEntity>>> getProjects({required String scope});
  Future<Either<Failure, ProjectDetailEntity>> getProjectDetail(String projectId);
  Future<Either<Failure, void>> launchProject(String projectId);
  Future<Either<Failure, void>> completeProject(String projectId);
}
