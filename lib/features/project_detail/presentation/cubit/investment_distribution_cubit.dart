import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/entities/investment_returns_entities.dart';
import 'package:vestie/features/project_detail/domain/usecases/investment_returns_usecases.dart';
import 'package:vestie/features/project_detail/presentation/mappers/investment_returns_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/project_detail_reload_coordinator.dart';

import 'investment_distribution_state.dart';

class InvestmentDistributionCubit extends Cubit<InvestmentDistributionState> {
  final InvestmentDistributionRouteArgs args;
  final PreviewInvestmentDistributionUseCase _previewUseCase;
  final ConfirmInvestmentDistributionUseCase _confirmUseCase;

  InvestmentDistributionCubit({
    required this.args,
    required PreviewInvestmentDistributionUseCase previewUseCase,
    required ConfirmInvestmentDistributionUseCase confirmUseCase,
  }) : _previewUseCase = previewUseCase,
       _confirmUseCase = confirmUseCase,
       super(
         InvestmentDistributionState(
           data: args.isPreview ? args.data : null,
           loadStatus: args.isPreview
               ? InvestmentDistributionLoadStatus.loaded
               : InvestmentDistributionLoadStatus.initial,
         ),
       );

  Future<void> load() async {
    if (args.isPreview) {
      final preview = args.data;
      if (preview != null) {
        emit(
          state.copyWith(
            loadStatus: InvestmentDistributionLoadStatus.loaded,
            data: preview,
          ),
        );
      }
      return;
    }

    final projectId = args.projectId.trim();
    if (projectId.isEmpty || args.distributeAmountUsd <= 0) {
      emit(
        state.copyWith(
          loadStatus: InvestmentDistributionLoadStatus.loadFailed,
          loadErrorMessage: AppStrings.errorGeneric,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loadStatus: InvestmentDistributionLoadStatus.loading,
        clearLoadError: true,
      ),
    );

    final result = await _previewUseCase(
      projectId: projectId,
      amount: args.distributeAmountUsd,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          loadStatus: InvestmentDistributionLoadStatus.loadFailed,
          loadErrorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (entity) => emit(
        InvestmentDistributionState(
          loadStatus: InvestmentDistributionLoadStatus.loaded,
          data: investmentDistributionUiDataFromPreview(
            projectId: projectId,
            projectName: args.projectName,
            entity: entity,
          ),
        ),
      ),
    );
  }

  Future<InvestmentDistributionResultEntity?> confirmDistribute() async {
    final projectId = args.projectId.trim();
    final data = state.data;
    if (projectId.isEmpty || data == null || state.isSubmitting) return null;

    emit(state.copyWith(isSubmitting: true, clearSubmitFailure: true));

    final result = await _confirmUseCase(
      projectId: projectId,
      amount: data.distributeAmountUsd,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false, submitFailure: failure));
        return null;
      },
      (distributeResult) async {
        await ProjectDetailReloadCoordinator.reload(projectId);
        emit(state.copyWith(isSubmitting: false));
        return distributeResult;
      },
    );
  }
}
