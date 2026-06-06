import 'dart:convert';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/project_summary_model.dart';

abstract class ProjectLocalDataSource {
  Future<void> cacheProjects(String scope, List<ProjectSummaryModel> projects);
  Future<List<ProjectSummaryModel>> getCachedProjects(String scope);
}

const String cachedProjectsPrefix = 'CACHED_PROJECTS_';

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final LocalStorage localStorage;

  ProjectLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheProjects(
    String scope,
    List<ProjectSummaryModel> projects,
  ) async {
    final key = '$cachedProjectsPrefix$scope';
    final jsonList = projects.map((p) => p.toJson()).toList();
    await localStorage.saveString(key, jsonEncode(jsonList));
  }

  @override
  Future<List<ProjectSummaryModel>> getCachedProjects(String scope) async {
    final key = '$cachedProjectsPrefix$scope';
    final jsonString = await localStorage.getString(key);

    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((e) => ProjectSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw const CacheFailure();
    }
  }
}
