import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/base_api_client.dart';
import '../../domain/entities/closure_vote_entities.dart';
import '../models/closure_voting_response_model.dart';

/// Week 10 closure-voting REST calls (`/projects/{id}/closure-voting/*`).
abstract class ClosureVotingRemoteDataSource {
  Future<OpenClosureVoteResponseModel> open({
    required String projectId,
    required int votingWindowDays,
    required ClosureVoteType voteType,
  });

  Future<CastClosureVoteResponseModel> cast({
    required String projectId,
    required bool voteForSuccess,
  });

  /// Returns `null` when no open vote (`404`).
  Future<ActiveClosureVoteResponseModel?> getActive(String projectId);

  Future<FinalizeClosureVoteResponseModel> finalize(String projectId);
}

class ClosureVotingRemoteDataSourceImpl implements ClosureVotingRemoteDataSource {
  final BaseApiClient apiClient;

  ClosureVotingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<OpenClosureVoteResponseModel> open({
    required String projectId,
    required int votingWindowDays,
    required ClosureVoteType voteType,
  }) async {
    final data = await apiClient.post<dynamic>(
      ApiConstants.projectClosureVotingOpen(projectId),
      data: {
        'votingWindowDays': votingWindowDays,
        'voteType': closureVoteTypeToApiValue(voteType),
      },
    );
    return OpenClosureVoteResponseModel.fromJson(
      parseClosureVotingResponseMap(data),
    );
  }

  @override
  Future<CastClosureVoteResponseModel> cast({
    required String projectId,
    required bool voteForSuccess,
  }) async {
    final data = await apiClient.post<dynamic>(
      ApiConstants.projectClosureVotingVote(projectId),
      data: {'vote': closureVoteValueToApiValue(voteForSuccess)},
    );
    return CastClosureVoteResponseModel.fromJson(
      parseClosureVotingResponseMap(data),
    );
  }

  @override
  Future<ActiveClosureVoteResponseModel?> getActive(String projectId) async {
    try {
      final response = await apiClient.dio.get<dynamic>(
        ApiConstants.projectClosureVotingActive(projectId),
      );
      final status = response.statusCode ?? 0;
      if (status == 404) return null;
      if (status < 200 || status >= 300) {
        throw FailureMapper.fromDioException(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }
      return ActiveClosureVoteResponseModel.fromJson(
        parseClosureVotingResponseMap(response.data),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw FailureMapper.fromDioException(e);
    }
  }

  @override
  Future<FinalizeClosureVoteResponseModel> finalize(String projectId) async {
    final data = await apiClient.post<dynamic>(
      ApiConstants.projectClosureVotingFinalize(projectId),
    );
    return FinalizeClosureVoteResponseModel.fromJson(
      parseClosureVotingResponseMap(data),
    );
  }
}
