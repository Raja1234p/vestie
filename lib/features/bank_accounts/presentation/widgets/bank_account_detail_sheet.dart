import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/bank_accounts/domain/entities/bank_account_entity.dart';
import 'package:vestie/features/bank_accounts/presentation/cubit/bank_accounts_cubit.dart';
import 'package:vestie/features/bank_accounts/presentation/widgets/bank_account_primary_badge.dart';

BankAccountEntity _accountFromState(
  List<BankAccountEntity> accounts,
  BankAccountEntity fallback,
) {
  for (final a in accounts) {
    if (a.id == fallback.id) return a;
  }
  return fallback;
}

class BankAccountDetailSheet extends StatelessWidget {
  final BankAccountEntity account;

  const BankAccountDetailSheet({super.key, required this.account});

  static Future<void> show(BuildContext context, BankAccountEntity account) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<BankAccountsCubit>(),
        child: BankAccountDetailSheet(account: account),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BankAccountsCubit, BankAccountsState>(
      builder: (context, state) {
        final current = _accountFromState(state.accounts, account);
        final isSettingDefault = state.settingDefaultAccountId == current.id;
        final isRemoving = state.removingAccountId == current.id;
        final isBusy = isSettingDefault || isRemoving;
        final bottomInset = math.max(
          60.h,
          MediaQuery.viewPaddingOf(context).bottom + 8.h,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: context.pop,
                child: AppSvgIcon(
                  assetPath: AppAssets.iconClose,
                  size: 24.w,
                  color: AppColors.grey900,
                ),
              ),
              SizedBox(height: 20.h),
              _BankSummaryCard(account: current),
              SizedBox(height: 28.h),
              _ActionRow(
                title: AppStrings.setDefaultBankLabel,
                subtitle: AppStrings.setDefaultBankSubtitle,
                trailing: isSettingDefault
                    ? SizedBox(
                        width: 52.w,
                        height: 30.h,
                        child: Center(
                          child: SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : _PrimaryToggleSwitch(
                        value: current.isDefault,
                        onChanged: isBusy
                            ? null
                            : (isDefault) async {
                                final error = await context
                                    .read<BankAccountsCubit>()
                                    .setDefault(
                                      current.id,
                                      isDefault: isDefault,
                                    );
                                if (!context.mounted) return;
                                if (error != null) {
                                  AppToast.showError(context, error);
                                }
                              },
                      ),
              ),
              SizedBox(height: 20.h),
              const AppPurpleDashedLine(
                color: AppColors.purple300,
                height: 1,
              ),
              SizedBox(height: 20.h),
              _ActionRow(
                title: AppStrings.removeBankLabel,
                subtitle: AppStrings.removeBankSubtitle,
                trailing: isRemoving
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.logoutBtn,
                        ),
                      )
                    : GestureDetector(
                        onTap: isBusy
                            ? null
                            : () async {
                                final error = await context
                                    .read<BankAccountsCubit>()
                                    .remove(current.id);
                                if (!context.mounted) return;
                                if (error != null) {
                                  AppToast.showError(context, error);
                                  return;
                                }
                                context.pop();
                                AppToast.showSuccess(
                                  context,
                                  AppStrings.bankRemovedSuccess,
                                );
                              },
                        child: AppSvgIcon(
                          assetPath: AppAssets.iconDelete,
                          size: 22.w,
                          color: AppColors.logoutBtn,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BankSummaryCard extends StatelessWidget {
  const _BankSummaryCard({required this.account});

  final BankAccountEntity account;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.appBgBottom,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  account.displayName,
                  style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (account.isDefault) const BankAccountPrimaryBadge(),
            ],
          ),
          if (account.last4.isNotEmpty) ...[
            SizedBox(height: 8.h),
            AppText(
              '•••• ${account.last4}',
              style: GoogleFonts.lato(
                fontSize: 15.sp,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: GoogleFonts.lato(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey1100,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 4.h),
              AppText(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        trailing,
      ],
    );
  }
}

class _PrimaryToggleSwitch extends StatelessWidget {
  const _PrimaryToggleSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;
    return GestureDetector(
      onTap: isEnabled ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isEnabled ? 1 : 0.7,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52.w,
          height: 30.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: value ? AppColors.primary : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(12.r),
            border: value
                ? Border.all(color: AppColors.primary, width: 1)
                : null,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
