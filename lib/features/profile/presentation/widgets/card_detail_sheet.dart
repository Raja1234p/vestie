import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_text.dart';
import '../../domain/entities/payment_card.dart';
import '../cubit/payment_methods_cubit.dart';
import 'card_preview.dart';
import 'payment_primary_button.dart';

/// Bottom sheet showing card details: set primary toggle, remove card.
class CardDetailSheet extends StatelessWidget {
  final PaymentCard card;
  const CardDetailSheet({super.key, required this.card});

  static Future<void> show(BuildContext context, PaymentCard card) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentMethodsCubit>(),
        child: CardDetailSheet(card: card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
      builder: (context, state) {
        // Get fresh card from state
        final current = state.cards.firstWhere(
          (c) => c.id == card.id,
          orElse: () => card,
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w,
              MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Close ────────────────────────────────────
              GestureDetector(
                onTap: context.pop,
                child: Icon(Icons.close, size: 24.w, color: AppColors.textBody),
              ),
              SizedBox(height: 16.h),

              // ── Card preview ──────────────────────────────
              CardPreview(card: current),
              SizedBox(height: 24.h),

              // ── Set primary toggle ────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          AppStrings.setPrimaryLabel,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          AppStrings.setPrimarySubtitle,
                          style: GoogleFonts.lato(
                            fontSize: 11.sp,
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: current.isPrimary,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                    onChanged: (val) {
                      if (val) {
                        context.read<PaymentMethodsCubit>().setPrimary(current.id);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              const Divider(),
              SizedBox(height: 4.h),

              // ── Remove card ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          AppStrings.removeCardLabel,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AppText(
                          AppStrings.removeCardSubtitle,
                          style: GoogleFonts.lato(
                            fontSize: 11.sp,
                            color: AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<PaymentMethodsCubit>().removeCard(current.id);
                      context.pop();
                      AppSnackBar.showSuccess(
                        context,
                        AppStrings.cardRemovedSuccess,
                      );
                    },
                    child: Icon(Icons.delete_outline_rounded,
                        size: 22.w, color: AppColors.logoutBtn),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // ── Add Card button ───────────────────────────
              PaymentPrimaryButton(
                label: AppStrings.btnAddCard,
                onTap: context.pop,
              ),
            ],
          ),
        );
      },
    );
  }
}
