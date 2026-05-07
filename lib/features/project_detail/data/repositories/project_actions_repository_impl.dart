import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/project_actions_repository.dart';
import '../datasources/project_actions_remote_data_source.dart';

class ProjectActionsRepositoryImpl implements ProjectActionsRepository {
  final ProjectActionsRemoteDataSource remoteDataSource;

  ProjectActionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> approveJoinRequest(String projectId, String userId) async {
    return _execute(() => remoteDataSource.approveJoinRequest(projectId, userId));
  }

  @override
  Future<Either<Failure, void>> rejectJoinRequest(String projectId, String userId) async {
    return _execute(() => remoteDataSource.rejectJoinRequest(projectId, userId));
  }

  @override
  Future<Either<Failure, void>> removeMember(String projectId, String userId) async {
    return _execute(() => remoteDataSource.removeMember(projectId, userId));
  }

  @override
  Future<Either<Failure, void>> promoteToCoLeader(String projectId, String userId) async {
    return _execute(() => remoteDataSource.promoteToCoLeader(projectId, userId));
  }

  @override
  Future<Either<Failure, void>> demoteCoLeader(String projectId, String userId) async {
    return _execute(() => remoteDataSource.demoteCoLeader(projectId, userId));
  }

  Future<Either<Failure, void>> _execute(Future<void> Function() action) async {
    try {
      await action();
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
