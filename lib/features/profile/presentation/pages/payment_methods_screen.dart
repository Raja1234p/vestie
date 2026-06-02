import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common/app_toast.dart';
import '../../../../core/widgets/common/app_shimmer.dart';
import '../../../../core/widgets/common/flow_screen_footer.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../domain/entities/payment_method_picker_behavior.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/payment_card_list.dart';
import '../widgets/payment_empty_view.dart';
import '../widgets/payment_primary_button.dart';
import '../widgets/profile_sub_header.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final bool isSelectionMode;
  final PaymentMethodPickerBehavior pickerBehavior;

  const PaymentMethodsScreen({
    super.key,
    this.isSelectionMode = false,
    this.pickerBehavior = PaymentMethodPickerBehavior.depositFlow,
  });

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) => PaymentMethodsCubit(
        listPaymentMethodsUseCase: sl.listPaymentMethodsUseCase,
        savePaymentCardViaSetupUseCase: sl.savePaymentCardViaSetupUseCase,
        setPrimaryPaymentMethodUseCase: sl.setPrimaryPaymentMethodUseCase,
        removePaymentMethodUseCase: sl.removePaymentMethodUseCase,
      ),
      child: _PaymentBody(
        isSelectionMode: isSelectionMode,
        pickerBehavior: pickerBehavior,
      ),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  final bool isSelectionMode;
  final PaymentMethodPickerBehavior pickerBehavior;

  const _PaymentBody({
    required this.isSelectionMode,
    required this.pickerBehavior,
  });

  Future<void> _openStripeAddCard(BuildContext context) async {
    final cubit = context.read<PaymentMethodsCubit>();
    final error = await cubit.addCardViaStripe(
      onBeforePresentPaymentSheet: () async {
        await WidgetsBinding.instance.endOfFrame;
      },
    );

    if (!context.mounted) return;

    if (error == null) {
      AppToast.showSuccess(context, AppStrings.cardSavedSuccess);
      return;
    }

    if (error != AppStrings.addCardStripeCancelled) {
      AppToast.showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
      listenWhen: (prev, next) =>
          prev.errorMessage != next.errorMessage &&
          next.errorMessage != null &&
          next.settingPrimaryCardId == null &&
          next.removingCardId == null &&
          !next.addingCard,
      listener: (context, state) {
        AppToast.showError(
          context,
          state.errorMessage ?? AppStrings.paymentMethodsLoadFailed,
        );
      },
      builder: (context, state) {
        final isEmpty = !state.loading && state.cards.isEmpty;
        final loadFailed =
            !state.loading && state.errorMessage != null && state.cards.isEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.paymentMethodsTitle),
                Expanded(
                  child: state.loading
                      ? const PaymentCardListShimmer()
                      : loadFailed
                          ? const PaymentEmptyView()
                          : isEmpty
                              ? const PaymentEmptyView()
                              : PaymentCardList(
                                  cards: state.cards,
                                  onAdd: () => _openStripeAddCard(context),
                                  isSelectionMode: isSelectionMode,
                                  pickerBehavior: pickerBehavior,
                                  addCardLoading: state.addingCard,
                                ),
                ),
                if (isEmpty)
                  FlowScreenFooter(
                    child: PaymentPrimaryButton(
                      label: AppStrings.btnAddCard,
                      onTap: state.addingCard
                          ? null
                          : () => _openStripeAddCard(context),
                      loading: state.addingCard,
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
