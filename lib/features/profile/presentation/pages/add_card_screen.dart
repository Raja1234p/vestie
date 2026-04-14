import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../cubit/add_card_cubit.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/profile_sub_header.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddCardCubit(),
      child: const _AddCardBody(),
    );
  }
}

class _AddCardBody extends StatefulWidget {
  const _AddCardBody();
  @override
  State<_AddCardBody> createState() => _AddCardBodyState();
}

class _AddCardBodyState extends State<_AddCardBody> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _save(BuildContext ctx) async {
    final cubit = ctx.read<AddCardCubit>();
    final card = await cubit.save();
    if (card != null && ctx.mounted) {
      // If PaymentMethodsCubit is in scope (pushed from there), add the card
      try {
        ctx.read<PaymentMethodsCubit>().addCard(card);
      } catch (_) {}
      AppSnackBar.showSuccess(ctx, AppStrings.cardSavedSuccess);
      Navigator.of(ctx).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCardCubit, AddCardState>(
      builder: (context, state) {
        final cubit = context.read<AddCardCubit>();
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              ProfileSubHeader(title: AppStrings.addCardTitle),

              // ── Fields ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Holder Name (system keyboard)
                      _CardFieldLabel(AppStrings.labelCardHolderName),
                      _CardTextField(
                        controller: _nameCtrl,
                        hint: AppStrings.hintCardHolder,
                        onTap: () => cubit.setActive(CardField.holderName),
                        onChanged: cubit.setHolderName,
                        active: state.activeField == CardField.holderName,
                      ),
                      SizedBox(height: 14.h),

                      // Card Number (custom keyboard)
                      _CardFieldLabel(AppStrings.labelCardNumber),
                      _CardDisplayField(
                        value: state.formattedCardNumber.isEmpty
                            ? AppStrings.hintCardNumber
                            : state.formattedCardNumber,
                        active: state.activeField == CardField.cardNumber,
                        isEmpty: state.cardNumber.isEmpty,
                        onTap: () => cubit.setActive(CardField.cardNumber),
                      ),
                      SizedBox(height: 14.h),

                      Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardFieldLabel(AppStrings.labelExpiryDate),
                            _CardDisplayField(
                              value: state.expiry.isEmpty
                                  ? AppStrings.hintExpiry
                                  : state.formattedExpiry,
                              active: state.activeField == CardField.expiry,
                              isEmpty: state.expiry.isEmpty,
                              onTap: () => cubit.setActive(CardField.expiry),
                            ),
                          ],
                        )),
                        SizedBox(width: 12.w),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardFieldLabel(AppStrings.labelCvv),
                            _CardDisplayField(
                              value: state.cvv.isEmpty
                                  ? AppStrings.hintCvv
                                  : state.cvv,
                              active: state.activeField == CardField.cvv,
                              isEmpty: state.cvv.isEmpty,
                              onTap: () => cubit.setActive(CardField.cvv),
                            ),
                          ],
                        )),
                      ]),
                      SizedBox(height: 20.h),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: state.saving
                              ? null
                              : () => _save(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardActionBtn,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: state.saving
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(AppStrings.btnSaveCard,
                                  style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),

              // ── Custom numeric keypad ────────────────────
              if (state.activeField != CardField.holderName)
                NumericKeypad(
                  onDigit: cubit.appendDigit,
                  onBackspace: cubit.backspace,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CardFieldLabel extends StatelessWidget {
  final String text;
  const _CardFieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(text,
          style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textBody)),
    );
  }
}

class _CardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final bool active;
  const _CardTextField({
    required this.controller, required this.hint,
    required this.onTap, required this.onChanged, required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.searchBarBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.cardBorder, width: active ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged, onTap: onTap,
        style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.authHint),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }
}

class _CardDisplayField extends StatelessWidget {
  final String value;
  final bool active;
  final bool isEmpty;
  final VoidCallback onTap;
  const _CardDisplayField({
    required this.value, required this.active,
    required this.isEmpty, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.searchBarBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: isEmpty ? AppColors.authHint : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
