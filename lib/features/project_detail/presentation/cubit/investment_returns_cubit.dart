import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/features/project_detail/domain/usecases/investment_returns_usecases.dart';
import 'package:vestie/features/project_detail/presentation/mappers/investment_returns_ui_mappers.dart';
import 'package:vestie/features/project_detail/presentation/models/investment_returns_ui_data.dart';

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
        distributionsLoadingMore: false,
        clearLoadError: true,
      ),
    );

    if (args.isLeaderView) {
      final result = await _getInvestmentDistributionsUseCase(projectId, page: 1);
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
            distributionsCurrentPage: entity.distributionsPagination.page,
            distributionsTotalCount: entity.distributionsPagination.totalCount,
          ),
        ),
      );
      return;
    }

    final result = await _getMyInvestmentReturnsUseCase(projectId, historyPage: 1);
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
          distributionsCurrentPage: entity.paymentHistoryPagination.page,
          distributionsTotalCount: entity.paymentHistoryPagination.totalCount,
        ),
      ),
    );
  }

  Future<void> loadMoreDistributions() async {
    if (state.loadStatus == InvestmentReturnsLoadStatus.loading ||
        state.distributionsLoadingMore ||
        !state.distributionsHasMore) {
      return;
    }

    final projectId = args.projectId?.trim();
    final projectName = args.projectName?.trim() ?? '';
    final currentData = state.data;
    if (projectId == null || projectId.isEmpty || currentData == null) return;

    emit(state.copyWith(distributionsLoadingMore: true, clearLoadError: true));
    final nextPage = state.distributionsCurrentPage + 1;

    if (args.isLeaderView) {
      final result = await _getInvestmentDistributionsUseCase(
        projectId,
        page: nextPage,
      );
      result.fold(
        (failure) => emit(
          state.copyWith(
            distributionsLoadingMore: false,
            loadErrorMessage: FailureMapper.userMessage(failure),
          ),
        ),
        (entity) {
          final pageUi = investmentReturnsUiDataFromDistributions(
            projectId: projectId,
            projectName: projectName,
            entity: entity,
          );
          emit(
            state.copyWith(
              data: InvestmentReturnsUiData(
                projectId: currentData.projectId,
                projectName: currentData.projectName,
                myContributionUsd: currentData.myContributionUsd,
                receivedSoFarUsd: currentData.receivedSoFarUsd,
                distributions: [
                  ...currentData.distributions,
                  ...pageUi.distributions,
                ],
                primarySummaryLabel: currentData.primarySummaryLabel,
                receivedCardLabel: currentData.receivedCardLabel,
                defaultLeftColumnLabel: currentData.defaultLeftColumnLabel,
                receivedCardAmountColor: currentData.receivedCardAmountColor,
              ),
              distributionsCurrentPage: entity.distributionsPagination.page,
              distributionsTotalCount: entity.distributionsPagination.totalCount,
              distributionsLoadingMore: false,
              clearLoadError: true,
            ),
          );
        },
      );
      return;
    }

    final result = await _getMyInvestmentReturnsUseCase(
      projectId,
      historyPage: nextPage,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          distributionsLoadingMore: false,
          loadErrorMessage: FailureMapper.userMessage(failure),
        ),
      ),
      (entity) {
        final pageUi = investmentReturnsUiDataFromMyReturns(
          projectId: projectId,
          projectName: projectName,
          entity: entity,
        );
        emit(
          state.copyWith(
            data: InvestmentReturnsUiData(
              projectId: currentData.projectId,
              projectName: currentData.projectName,
              myContributionUsd: currentData.myContributionUsd,
              receivedSoFarUsd: currentData.receivedSoFarUsd,
              distributions: [
                ...currentData.distributions,
                ...pageUi.distributions,
              ],
              primarySummaryLabel: currentData.primarySummaryLabel,
              receivedCardLabel: currentData.receivedCardLabel,
              defaultLeftColumnLabel: currentData.defaultLeftColumnLabel,
              receivedCardAmountColor: currentData.receivedCardAmountColor,
            ),
            distributionsCurrentPage: entity.paymentHistoryPagination.page,
            distributionsTotalCount: entity.paymentHistoryPagination.totalCount,
            distributionsLoadingMore: false,
            clearLoadError: true,
          ),
        );
      },
    );
  }
}
