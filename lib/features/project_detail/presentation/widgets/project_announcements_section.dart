import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/presentation/widgets/list_load_more_footer.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

import '../../domain/entities/project_announcement_entity.dart';
import '../../domain/entities/project_detail_entity.dart';
import 'announcement_card.dart';

/// Project announcements from `GET /projects/{id}` → `announcements[]`.
///
/// Visible to every member when the list is non-empty. Swipe-to-delete is only
/// enabled for [ProjectDetailEntity.isModeratorView] (GroupLeader / CoLeader).
class ProjectAnnouncementsSection extends StatefulWidget {
  final ProjectDetailEntity project;

  /// Returns `true` when the API delete succeeded.
  final Future<bool> Function(String announcementId)? onDeleteAnnouncement;

  /// Vertical gap above the first card (omitted when there are no announcements).
  final double gapBefore;

  /// Vertical gap below the last card (omitted when there are no announcements).
  final double gapAfter;

  const ProjectAnnouncementsSection({
    super.key,
    required this.project,
    this.onDeleteAnnouncement,
    this.gapBefore = 0,
    this.gapAfter = 0,
  });

  @override
  State<ProjectAnnouncementsSection> createState() =>
      _ProjectAnnouncementsSectionState();
}

class _ProjectAnnouncementsSectionState
    extends State<ProjectAnnouncementsSection> {
  late List<ProjectAnnouncementEntity> _visible;

  bool get _canDelete => widget.project.isModeratorView;

  @override
  void initState() {
    super.initState();
    _syncFromProject();
  }

  @override
  void didUpdateWidget(covariant ProjectAnnouncementsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.announcements != widget.project.announcements) {
      _syncFromProject();
    }
  }

  void _syncFromProject() {
    _visible = List<ProjectAnnouncementEntity>.from(
      widget.project.announcements,
    );
  }

  void _onDismissed(String id) {
    final index = _visible.indexWhere((a) => a.id == id);
    if (index < 0) return;

    final removed = _visible[index];
    setState(() => _visible.removeAt(index));

    final delete = widget.onDeleteAnnouncement;
    if (delete == null) return;

    delete(id).then((ok) {
      if (!mounted || ok) return;
      setState(() {
        final insertAt = index.clamp(0, _visible.length);
        _visible.insert(insertAt, removed);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.gapBefore > 0) SizedBox(height: widget.gapBefore),
        for (var i = 0; i < _visible.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          AnnouncementCard(
            announcementId: _visible[i].id,
            heading: _visible[i].heading,
            text: _visible[i].content,
            attachmentImageUrls: _visible[i].attachmentImageUrls,
            canDeleteAnnouncement: _canDelete,
            onDelete: _canDelete && widget.onDeleteAnnouncement != null
                ? () => _onDismissed(_visible[i].id)
                : null,
          ),
        ],
        _buildLoadMore(context),
        if (widget.gapAfter > 0) SizedBox(height: widget.gapAfter),
      ],
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    ProjectDetailBloc? bloc;
    try {
      bloc = context.read<ProjectDetailBloc>();
    } on ProviderNotFoundException {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ProjectDetailBloc, ProjectDetailState>(
      bloc: bloc,
      buildWhen: (prev, curr) =>
          prev is ProjectDetailLoaded &&
          curr is ProjectDetailLoaded &&
          (prev.project.announcementsPagination !=
                  curr.project.announcementsPagination ||
              prev.announcementsLoadingMore != curr.announcementsLoadingMore),
      builder: (context, state) {
        if (state is! ProjectDetailLoaded) return const SizedBox.shrink();
        if (!state.project.announcementsPagination.hasMore) {
          return const SizedBox.shrink();
        }

        if (state.announcementsLoadingMore) {
          return const ListLoadMoreFooter(loadingMore: true);
        }

        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Center(
            child: TextButton(
              onPressed: () => bloc!.add(const LoadMoreProjectAnnouncementsEvent()),
              child: AppText(
                AppStrings.loadMore,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
