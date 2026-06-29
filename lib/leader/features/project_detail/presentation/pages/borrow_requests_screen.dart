import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vestie/core/presentation/paginated_scroll_listener.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer_lists.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity.dart';
import 'package:vestie/features/project_detail/domain/entities/borrow_request_entity_extensions.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_entity.dart';
import 'package:vestie/features/project_detail/presentation/navigation/project_detail_navigation.dart';
import 'package:vestie/features/project_detail/presentation/widgets/borrow_requests_empty_state.dart';
import 'package:vestie/user/features/borrow/presentation/navigation/borrow_project_detail_sync.dart';

import '../widgets/borrow_request_card.dart';
import '../widgets/borrow_request_decision_dialogs.dart';

/// Full-screen borrow requests list.
class BorrowRequestsScreen extends StatefulWidget {
  final List<BorrowRequestEntity> requests;
  final bool isLeaderMode;
  final String projectId;
  final String? screenTitle;
  final ProjectDetailEntity? project;

  const BorrowRequestsScreen({
    super.key,
    required this.requests,
    required this.projectId,
    this.isLeaderMode = false,
    this.screenTitle,
    this.project,
  });

  @override
  State<BorrowRequestsScreen> createState() => _BorrowRequestsScreenState();
}

class _BorrowRequestsScreenState extends State<BorrowRequestsScreen> {
  late List<BorrowRequestEntity> _requests;
  bool _loading = true;
  bool _loadingMore = false;
  int _currentPage = 0;
  int _totalCount = 0;
  final ScrollController _scrollController = ScrollController();
  PaginatedScrollListener? _scrollListener;

  bool get _hasMore => _requests.length < _totalCount;

  @override
  void initState() {
    super.initState();
    _requests = List<BorrowRequestEntity>.from(widget.requests);
    _scrollListener = PaginatedScrollListener(
      controller: _scrollController,
      onLoadMore: _loadMore,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadRequests();
    });
  }

  @override
  void dispose() {
    _scrollListener?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _reloadRequests() async {
    setState(() => _loading = true);
    final result = await ServiceLocator.instance.listBorrowRequestsUseCase(
      projectId: widget.projectId,
      status: 'Pending',
      page: 1,
    );
    if (!mounted) return;
    result.fold(
      (_) {
        setState(() => _loading = false);
      },
      (page) => setState(() {
        _requests = page.items;
        _currentPage = page.page;
        _totalCount = page.totalCount;
        _loading = false;
      }),
    );
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final result = await ServiceLocator.instance.listBorrowRequestsUseCase(
      projectId: widget.projectId,
      status: 'Pending',
      page: _currentPage + 1,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loadingMore = false),
      (page) => setState(() {
        _requests = [..._requests, ...page.items];
        _currentPage = page.page;
        _totalCount = page.totalCount;
        _loadingMore = false;
      }),
    );
  }

  VoidCallback? _openMemberDetail(
    BuildContext context,
    BorrowRequestEntity request,
  ) {
    final p = widget.project;
    if (p == null || !p.canReviewMemberProfiles) return null;

    final member = request.resolveMember(p.members);
    if (member == null) return null;

    return () {
      ProjectDetailNavigation.openMemberProfile(
        context,
        project: p,
        member: member,
      );
    };
  }

  Future<bool> _approve(
    BuildContext context,
    BorrowRequestEntity request,
  ) async {
    final result = await ServiceLocator.instance.approveBorrowRequestUseCase(
      projectId: widget.projectId,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppToast.showError(context, failure.message);
      return false;
    }, (_) async {
      await BorrowProjectDetailSync.reloadBeforeSuccess(widget.projectId);
      if (!context.mounted) return false;
      await _reloadRequests();
      return true;
    });
  }

  Future<bool> _reject(
    BuildContext context,
    BorrowRequestEntity request,
  ) async {
    final result = await ServiceLocator.instance.rejectBorrowRequestUseCase(
      projectId: widget.projectId,
      borrowRequestId: request.id,
    );
    return result.fold((failure) {
      AppToast.showError(context, failure.message);
      return false;
    }, (_) async {
      await BorrowProjectDetailSync.reloadBeforeSuccess(widget.projectId);
      if (!context.mounted) return false;
      await _reloadRequests();
      return true;
    });
  }

  Future<void> _onVoteSuccess() async {
    await BorrowProjectDetailSync.reloadBeforeSuccess(widget.projectId);
    if (!mounted) return;
    await _reloadRequests();
  }

  Widget _buildRequestCard(BuildContext context, BorrowRequestEntity request) {
    final project = widget.project;
    return BorrowRequestCard(
      key: ValueKey(
        '${request.id}|${request.callerVote}|'
        '${request.upvotes}|${request.downvotes}',
      ),
      projectId: widget.projectId,
      request: request,
      actionMode: widget.isLeaderMode
          ? BorrowRequestActionMode.decision
          : BorrowRequestActionMode.vote,
      hideVoteActions:
          !widget.isLeaderMode &&
          project != null &&
          request.isRequestedByViewer(project),
      onOpenMemberDetail: _openMemberDetail(context, request),
      onAccept: widget.isLeaderMode
          ? () => showApproveBorrowRequestFlow(
              context,
              request,
              () => _approve(context, request),
            )
          : null,
      onReject: widget.isLeaderMode
          ? () => showRejectBorrowRequestFlow(
              context,
              request,
              () => _reject(context, request),
            )
          : null,
      onVoteSuccess: widget.isLeaderMode ? null : _onVoteSuccess,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return ListView(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
        children: const [BorrowRequestListShimmer()],
      );
    }
    if (_requests.isEmpty) {
      return const BorrowRequestsEmptyState(centered: true);
    }
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
      itemCount: _requests.length + 1,
      itemBuilder: (_, i) {
        if (i == _requests.length) {
          return ListLoadMoreFooter(loadingMore: _loadingMore);
        }
        return _buildRequestCard(context, _requests[i]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: widget.screenTitle ?? AppStrings.borrowRequestsTitle,
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }
}
