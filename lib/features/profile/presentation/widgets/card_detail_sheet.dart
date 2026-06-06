import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/widgets/common/app_purple_dashed_line.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/presentation/cubit/payment_methods_cubit.dart';
import 'package:vestie/features/profile/presentation/widgets/card_preview.dart';

/// Bottom sheet: card preview, set-primary toggle, remove card (Figma).
class CardDetailSheet extends StatefulWidget {
  final PaymentCard card;
  const CardDetailSheet({super.key, required this.card});

  static Future<void> show(BuildContext context, PaymentCard card) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentMethodsCubit>(),
        child: CardDetailSheet(card: card),
      ),
    );
  }

  @override
  State<CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends State<CardDetailSheet> {
  PaymentCard? _detailCard;
  bool _loadingDetail = true;

  @override
  void initState() {
    super.initState();
    _refreshFromApi();
  }

  Future<void> _refreshFromApi() async {
    final result = await ServiceLocator.instance.getPaymentMethodUseCase(
      widget.card.id,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _detailCard = widget.card;
        _loadingDetail = false;
      }),
      (card) => setState(() {
        _detailCard = card;
        _loadingDetail = false;
      }),
    );
  }

  PaymentCard _resolveCard(PaymentMethodsState state) {
    final refreshed = _detailCard ?? widget.card;
    return state.cards.firstWhere(
      (c) => c.id == refreshed.id,
      orElse: () => refreshed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
      builder: (context, state) {
        final current = _resolveCard(state);
        final isSettingPrimary = state.settingPrimaryCardId == current.id;
        final isRemoving = state.removingCardId == current.id;
        final isBusy = isSettingPrimary || isRemoving;
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
              if (_loadingDetail)
                SizedBox(
                  height: 180.h,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                CardPreview(card: current),
              SizedBox(height: 28.h),
              _ActionRow(
                title: AppStrings.setPrimaryLabel,
                subtitle: AppStrings.setPrimarySubtitle,
                trailing: isSettingPrimary
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
                        value: current.isPrimary,
                        onChanged: _loadingDetail || isBusy
                            ? null
                            : (isPrimary) async {
                                final error = await context
                                    .read<PaymentMethodsCubit>()
                                    .setPrimary(
                                      current.id,
                                      isPrimary: isPrimary,
                                    );
                                if (!context.mounted) return;
                                if (error != null) {
                                  AppToast.showError(context, error);
                                }
                              },
                      ),
              ),
              SizedBox(height: 20.h),
              const AppPurpleDashedLine(color: AppColors.purple300, height: 1),
              SizedBox(height: 20.h),
              _ActionRow(
                title: AppStrings.removeCardLabel,
                subtitle: AppStrings.removeCardSubtitle,
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
                        onTap: _loadingDetail || isBusy
                            ? null
                            : () async {
                                final error = await context
                                    .read<PaymentMethodsCubit>()
                                    .removeCard(current.id);
                                if (!context.mounted) return;
                                if (error != null) {
                                  AppToast.showError(context, error);
                                  return;
                                }
                                context.pop();
                                AppToast.showSuccess(
                                  context,
                                  AppStrings.cardRemovedSuccess,
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
  const _PrimaryToggleSwitch({required this.value, required this.onChanged});

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
