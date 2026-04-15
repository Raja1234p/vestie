import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../cubit/add_card_cubit.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/card_input_formatters.dart';
import '../widgets/payment_primary_button.dart';
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
  final _nameCtrl = TextEditingController(), _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController(), _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext ctx) async {
    final cubit = ctx.read<AddCardCubit>();
    final card = await cubit.save();
    if (card != null && ctx.mounted) {
      // If PaymentMethodsCubit is in scope (pushed from there), add the card
      try {
        ctx.read<PaymentMethodsCubit>().addCard(card);
      } catch (_) {}
      AppSnackBar.showSuccess(ctx, AppStrings.cardSavedSuccess);
      ctx.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCardCubit, AddCardState>(
      builder: (context, state) {
        final cubit = context.read<AddCardCubit>();
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: Column(
            children: [
              ProfileSubHeader(title: AppStrings.addCardTitle),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: Column(
                    children: [
                      AppTextField(
                        label: AppStrings.labelCardHolderName,
                        hint: AppStrings.hintCardHolder,
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        onChanged: cubit.setHolderName,
                        errorText: state.holderNameError,
                      ),
                      SizedBox(height: 14.h),
                      AppTextField(
                        label: AppStrings.labelCardNumber,
                        hint: AppStrings.hintCardNumber,
                        controller: _numberCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          const CardNumberInputFormatter(),
                        ],
                        onChanged: cubit.setCardNumber,
                        errorText: state.cardNumberError,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: AppStrings.labelExpiryDate,
                              hint: AppStrings.hintExpiry,
                              controller: _expiryCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                const ExpiryInputFormatter(),
                              ],
                              onChanged: cubit.setExpiry,
                              errorText: state.expiryError,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: AppTextField(
                              label: AppStrings.labelCvv,
                              hint: AppStrings.hintCvv,
                              controller: _cvvCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              onChanged: cubit.setCvv,
                              onSubmitted: (_) {
                                if (!state.saving) _save(context);
                              },
                              errorText: state.cvvError,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      PaymentPrimaryButton(
                        label: AppStrings.btnSaveCard,
                        onTap: state.saving ? null : () => _save(context),
                        loading: state.saving,
                      ),
                      SizedBox(height: 16.h),
                    ],
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
