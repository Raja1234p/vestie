import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/project_detail_flow_args.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import 'package:vestie/features/project_detail/presentation/widgets/project_detail_preview_link.dart';
import 'package:vestie/user/features/borrow/presentation/models/my_borrow_approved_ui_data.dart';

import '../data/my_borrow_request_args_builder.dart';
import '../navigation/borrow_repay_navigation.dart';
import '../widgets/cancel_borrow_request_dialog.dart';
import '../widgets/my_borrow_approved_body.dart';
import '../widgets/my_borrow_request_active_body.dart';

enum _MyBorrowPreviewKind { none, pending, approved }

/// Member My Borrow Request — empty, pending, and approved (My Borrow) states.
class MyBorrowRequestScreen extends StatefulWidget {
  final MyBorrowRequestRouteArgs args;

  const MyBorrowRequestScreen({super.key, required this.args});

  @override
  State<MyBorrowRequestScreen> createState() => _MyBorrowRequestScreenState();
}

class _MyBorrowRequestScreenState extends State<MyBorrowRequestScreen> {
  _MyBorrowPreviewKind _previewKind = _MyBorrowPreviewKind.none;

  bool get _hasRealApproved => widget.args.approvedBorrow != null;

  bool get _hasRealActiveRequest => widget.args.activeRequest != null;

  bool get _showsApproved =>
      _hasRealApproved || _previewKind == _MyBorrowPreviewKind.approved;

  bool get _showsPending =>
      !_showsApproved &&
      (_hasRealActiveRequest || _previewKind == _MyBorrowPreviewKind.pending);

  bool get _canShowDevPreviews =>
      !_hasRealApproved && !_hasRealActiveRequest;

  String get _headerTitle => _showsApproved
      ? AppStrings.myBorrowTitle
      : AppStrings.myBorrowRequestTitle;

  BorrowRequestEntity get _displayRequest =>
      widget.args.activeRequest ?? MyBorrowRequestArgsBuilder.pendingPreviewRequest();

  List<MyBorrowHistoryEntry> get _displayHistory => _hasRealActiveRequest
      ? widget.args.history
      : MyBorrowRequestArgsBuilder.pendingPreviewHistory();

  MyBorrowApprovedUiData get _displayApproved =>
      widget.args.approvedBorrow ?? MyBorrowRequestArgsBuilder.approvedPreview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: _headerTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(child: _buildBody()),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 15.h),
                child: _buildPrimaryButton(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    if (_showsApproved) {
      return AppButton(
        text: AppStrings.btnRepayBorrowAmount,
        onPressed: _onRepayPressed,
        useGradient: false,
        hasShadow: false,
        color: AppColors.purple700,
        borderRadius: 12.r,
      );
    }

    return AppButton(
      text: _showsPending
          ? AppStrings.btnCancelBorrowRequest
          : AppStrings.btnMakeBorrowRequest,
      onPressed: () => _onPrimaryAction(context),
      useGradient: false,
      hasShadow: false,
      color: _showsPending ? AppColors.red900 : AppColors.grey1200,
      borderRadius: 12.r,
    );
  }

  Widget _buildBody() {
    if (_showsApproved) {
      return SingleChildScrollView(
        child: MyBorrowApprovedBody(data: _displayApproved),
      );
    }

    if (_showsPending) {
      return SingleChildScrollView(
        child: MyBorrowRequestActiveBody(
          activeRequest: _displayRequest,
          history: _displayHistory,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_canShowDevPreviews) ...[
          ProjectDetailPreviewLink(
            label: AppStrings.btnPreviewPendingBorrowRequest,
            onPressed: () => setState(
              () => _previewKind = _MyBorrowPreviewKind.pending,
            ),
          ),
          ProjectDetailPreviewLink(
            label: AppStrings.btnPreviewApprovedBorrowRequest,
            onPressed: () => setState(
              () => _previewKind = _MyBorrowPreviewKind.approved,
            ),
          ),
        ],
        const Expanded(
          child: BorrowRequestsEmptyState(
            centered: true,
            subtitle: AppStrings.borrowRequestsEmptySubtitle,
          ),
        ),
      ],
    );
  }

  void _onRepayPressed() {
    BorrowRepayNavigation.startRepayFlow(
      context,
      projectId: widget.args.projectId,
      projectName: widget.args.projectName.isNotEmpty
          ? widget.args.projectName
          : 'Europe Trip 2025',
      approved: _displayApproved,
    );
  }

  void _onPrimaryAction(BuildContext context) {
    if (_showsPending) {
      showCancelBorrowRequestDialog(
        context,
        onConfirm: () {
          if (!context.mounted) return;
          if (_previewKind == _MyBorrowPreviewKind.pending &&
              !_hasRealActiveRequest) {
            setState(() => _previewKind = _MyBorrowPreviewKind.none);
            return;
          }
          context.pop();
        },
      );
      return;
    }
    context.push(AppRoutes.borrowFlow, extra: widget.args.walletFlowArgs);
  }
}
