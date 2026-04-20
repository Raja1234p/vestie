import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';

/// Figma-accurate project card.
///
/// Ongoing  : category chip | status badge | project name | goal + progress + date | action button
/// Completed: project-name chip | ✓ Completed badge | "Raised/Total $X" large | button only for Joined
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onAction;

  const ProjectCard({super.key, required this.project, required this.onAction});

  bool get _showButton =>
      project.status == ProjectStatus.ongoing ||
      project.relation == ProjectRelation.joined;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.purple300.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBody.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category / project-name chip + status badge ───
          Row(
            children: [
              _CategoryChip(project: project),
              const Spacer(),
              _StatusBadge(status: project.status),
            ],
          ),
          SizedBox(height: 8.h),

          // ── Main content differs by status ────────────────
          if (project.status == ProjectStatus.ongoing) ...[
            // Project name
            Text(
              project.name,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (project.description != null) ...[
              SizedBox(height: 2.h),
              Text(project.description!,
                  style: GoogleFonts.lato(
                      fontSize: 11.sp, color: AppColors.textBody)),
            ],
            if (project.goalAmount != null) ...[
              SizedBox(height: 8.h),
              _GoalRow(project: project),
              SizedBox(height: 6.h),
              _ProgressBar(progress: project.progress),
              SizedBox(height: 6.h),
              _DateRow(endsIn: project.endsIn ?? ''),
            ],
          ] else ...[
            // Completed — raised/total amount as main large text
            Text(
              _raisedText,
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          if (_showButton) ...[
            SizedBox(height: 12.h),
            _ActionButton(project: project, onTap: onAction),
          ],
        ],
      ),
    );
  }

  String get _raisedText {
    final amount = _formatWhole(project.currentAmount);
    final prefix = project.relation == ProjectRelation.owned
        ? AppStrings.labelRaised
        : 'Total';
    return '$prefix \$$amount';
  }

  String _formatWhole(double? value) {
    final raw = (value ?? 0).toStringAsFixed(0);
    final parts = raw.split('');
    final buf = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
      buf.write(parts[i]);
    }
    return buf.toString();
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final Project project;
  const _CategoryChip({required this.project});

  String get _label => project.status == ProjectStatus.completed
      ? project.name        // completed → show project name in chip
      : project.categoryLabel; // ongoing → show category

  IconData get _icon {
    switch (project.category) {
      case ProjectCategory.vacations:  return Icons.beach_access_outlined;
      case ProjectCategory.emergency:  return Icons.shield_outlined;
      case ProjectCategory.investment: return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12.w, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(_label,
              style: GoogleFonts.lato(
                  fontSize: 11.sp,
                  color: AppColors.textBody,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final ongoing = status == ProjectStatus.ongoing;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ongoing
              ? const [
                  AppColors.blue600,
                  AppColors.blue800, // #2E62C2
                ]
              : const [
                  AppColors.green600,
                  AppColors.green800, // #159A68
                ],
        ),
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: (ongoing ? AppColors.blue800 : AppColors.green800)
                .withValues(alpha: 0.24),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!ongoing) ...[
            Icon(Icons.check_circle_rounded,
                size: 11.w, color: AppColors.surface),
            SizedBox(width: 3.w),
          ],
          Text(
            ongoing ? AppStrings.statusOnGoing : AppStrings.statusCompleted,
            style: GoogleFonts.lato(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Goal row ──────────────────────────────────────────────────────────────────
class _GoalRow extends StatelessWidget {
  final Project project;
  const _GoalRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final current = _formatWhole(project.currentAmount);
    final goal = _formatWhole(project.goalAmount);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 25.sp, color: AppColors.textBody),
            children: [
              TextSpan(
                text: '${AppStrings.labelGoal} ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '\$$current',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        Padding(
          padding: EdgeInsets.only(bottom: 3.h),
          child: Text(
            '/ \$$goal',
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ),
      ],
    );
  }

  String _formatWhole(double? value) {
    final raw = (value ?? 0).toStringAsFixed(0);
    final parts = raw.split('');
    final buf = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
      buf.write(parts[i]);
    }
    return buf.toString();
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.r),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 12.h,
        backgroundColor: AppColors.progressBg,
        valueColor: const AlwaysStoppedAnimation(AppColors.progressFill),
      ),
    );
  }
}

// ── Date row ──────────────────────────────────────────────────────────────────
class _DateRow extends StatelessWidget {
  final String endsIn;
  const _DateRow({required this.endsIn});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time_outlined,
            size: 12.w, color: AppColors.textBody),
        SizedBox(width: 4.w),
        Text(
          '${AppStrings.labelEndsIn} ',
          style: GoogleFonts.lato(fontSize: 13.sp, color: AppColors.textBody),
        ),
        Text(
          endsIn,
          style: GoogleFonts.lato(fontSize: 13.sp, color: AppColors.textBody,fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const _ActionButton({required this.project, required this.onTap});

  String get _label {
    if (project.relation == ProjectRelation.owned) return AppStrings.btnView;
    if (project.requestPending) return AppStrings.btnSendRequest;
    return AppStrings.btnJoin;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardActionBtn,
          foregroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          _label,
          style: GoogleFonts.lato(
              fontSize: 13.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
