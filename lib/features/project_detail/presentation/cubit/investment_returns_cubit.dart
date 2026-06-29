import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/usecases/investment_returns_usecases.dart';
import 'package:vestie/features/project_detail/presentation/mappers/investment_returns_ui_mappers.dart';

import 'investment_returns_state.dart';

class InvestmentReturnsCubit extends Cubit<InvestmentReturnsState> {
  final InvestmentReturnsRouteArgs args;
  final GetMyInvestmentReturnsUseCase _getMyInvestmentReturnsUseCase;
  final GetInvestmentDistributionsUseCase _getInvestmentDistributionsUseCase;

  InvestmentReturnsCubit({
    required this.args,
    required GetMyInvestmentReturnsUseCase getMyInvestmentReturnsUseCase,
    required GetInvestmentDistributionsUseCase getInvestmentDistributionsUseCase,
  }) : _getMyInvestmentReturnsUseCase = getMyInvestmentReturnsUseCase,
       _getInvestmentDistributionsUseCase = getInvestmentDistributionsUseCase,
       super(
         InvestmentReturnsState(
           data: args.isPreview ? args.data : null,
           loadStatus: args.isPreview
               ? InvestmentReturnsLoadStatus.loaded
               : InvestmentReturnsLoadStatus.initial,
         ),
       );

  Future<void> load() async {
    if (args.isPreview) {
      final preview = args.data;
      if (preview != null) {
        emit(
          state.copyWith(
            loadStatus: InvestmentReturnsLoadStatus.loaded,
            data: preview,
          ),
        );
      }
      return;
    }

    final projectId = args.projectId?.trim();
    final projectName = args.projectName?.trim() ?? '';
    if (projectId == null || projectId.isEmpty) {
      emit(
        state.copyWith(
          loadStatus: InvestmentReturnsLoadStatus.loadFailed,
          loadErrorMessage: AppStrings.errorGeneric,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadStatus: InvestmentReturnsLoadStatus.loading,
        clearLoadError: true,
      ),
    );

    if (args.isLeaderView) {
      final result = await _getInvestmentDistributionsUseCase(projectId);
      result.fold(
        (failure) => emit(
          state.copyWith(
            loadStatus: InvestmentReturnsLoadStatus.loadFailed,
            loadErrorMessage: FailureMapper.userMessage(failure),
          ),
        ),
        (entity) => emit(
          InvestmentReturnsState(
            loadStatus: InvestmentReturnsLoadStatus.loaded,
            data: investmentReturnsUiDataFromDistributions(
              projectId: projectId,
              projectName: projectName,
              entity: entity,
            ),
          ),
        ),
      );
      return;
    }

    final result = await _getMyInvestmentReturnsUseCase(projectId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          loadStatus: InvestmentReturnsLoadStatus.loadFailed,
          loadErrorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (entity) => emit(
        InvestmentReturnsState(
          loadStatus: InvestmentReturnsLoadStatus.loaded,
          data: investmentReturnsUiDataFromMyReturns(
            projectId: projectId,
            projectName: projectName,
            entity: entity,
          ),
        ),
      ),
    );
  }
}
