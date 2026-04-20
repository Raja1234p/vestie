import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project_detail_entity.dart';
import '../../../home/domain/entities/project.dart';

/// Project info card: category chip, status badge, goal amount, deadline.
class ProjectInfoCard extends StatelessWidget {
  final ProjectDetailEntity project;

  const ProjectInfoCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Category chip + Status badge ──────────────
          Row(
            children: [
              _CategoryChip(project: project),
              const Spacer(),
              _StatusBadge(status: project.status),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Goal amount ─────────────────────────────────────
          _GoalRow(goal: project.goalAmount, current: project.currentAmount),
          SizedBox(height: 8.h),

          // ── Deadline ────────────────────────────────────────
          _DeadlineRow(endsIn: project.endsIn),
        ],
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final ProjectDetailEntity project;
  const _CategoryChip({required this.project});

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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13.w, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            project.categoryLabel,
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              color: AppColors.textBody,
              fontWeight: FontWeight.w500,
            ),
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ongoing
              ? const [AppColors.blue600, AppColors.blue800]
              : const [AppColors.green600, AppColors.green800],
        ),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        ongoing ? AppStrings.statusOnGoing : AppStrings.statusCompleted,
        style: GoogleFonts.lato(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
        ),
      ),
    );
  }
}

// ── Goal row ──────────────────────────────────────────────────────────────────
class _GoalRow extends StatelessWidget {
  final double goal;
  final double current;
  const _GoalRow({required this.goal, required this.current});

  String _fmt(double v) =>
      v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.lato(fontSize: 28.sp, color: AppColors.textPrimary),
        children: [
          TextSpan(
            text: AppStrings.goalPrefix,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: '\$${_fmt(current)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(
            text: '  / \$${_fmt(goal)}',
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Deadline row ──────────────────────────────────────────────────────────────
class _DeadlineRow extends StatelessWidget {
  final String endsIn;
  const _DeadlineRow({required this.endsIn});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 14.w, color: AppColors.textBody),
        SizedBox(width: 6.w),
        Text(
          '${AppStrings.labelEndsIn} ',
          style: GoogleFonts.lato(fontSize: 13.sp, color: AppColors.textBody),
        ),
        Text(
          endsIn,
          style: GoogleFonts.lato(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
