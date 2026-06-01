import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/person_name_input_formatter.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/text/app_text.dart';
import '../cubit/add_card_cubit.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/card_input_formatters.dart';
import '../widgets/payment_primary_button.dart';
import '../widgets/profile_sub_header.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) => AddCardCubit(
        savePaymentCardUseCase: sl.savePaymentCardUseCase,
        savePaymentCardViaSetupUseCase: sl.savePaymentCardViaSetupUseCase,
      ),
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
    if (ctx.mounted && cubit.state.saveError != null) {
      AppSnackBar.showError(ctx, cubit.state.saveError!);
      return;
    }
    if (card != null && ctx.mounted) {
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
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.addCardTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                    child: kDebugMode
                        ? _DebugCardForm(
                            nameCtrl: _nameCtrl,
                            numberCtrl: _numberCtrl,
                            expiryCtrl: _expiryCtrl,
                            cvvCtrl: _cvvCtrl,
                            state: state,
                            cubit: cubit,
                            onSave: () => _save(context),
                          )
                        : const _ReleaseStripeAddCard(),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                    child: PaymentPrimaryButton(
                      label: AppStrings.btnSaveCard,
                      onTap: state.saving ? null : () => _save(context),
                      loading: state.saving,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReleaseStripeAddCard extends StatelessWidget {
  const _ReleaseStripeAddCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          AppStrings.addCardStripeSubtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
            height: 1.45,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _DebugCardForm extends StatelessWidget {
  const _DebugCardForm({
    required this.nameCtrl,
    required this.numberCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.state,
    required this.cubit,
    required this.onSave,
  });

  final TextEditingController nameCtrl;
  final TextEditingController numberCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final AddCardState state;
  final AddCardCubit cubit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: AppStrings.labelCardHolderName,
          hint: AppStrings.hintCardHolder,
          controller: nameCtrl,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            PersonNameInputFormatter(allowSpaces: true),
          ],
          onChanged: cubit.setHolderName,
          errorText: state.holderNameError,
        ),
        SizedBox(height: 14.h),
        AppTextField(
          label: AppStrings.labelCardNumber,
          hint: AppStrings.hintCardNumber,
          controller: numberCtrl,
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
        SizedBox(height: 14.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: AppStrings.labelExpiryDate,
                hint: AppStrings.hintExpiry,
                controller: expiryCtrl,
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
                controller: cvvCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: cubit.setCvv,
                onSubmitted: (_) {
                  if (!state.saving) onSave();
                },
                errorText: state.cvvError,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
