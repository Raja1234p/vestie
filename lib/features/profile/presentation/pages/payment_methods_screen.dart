import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/common/app_loader.dart';
import '../../../../core/widgets/common/flow_screen_footer.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../cubit/payment_methods_cubit.dart';
import '../widgets/payment_card_list.dart';
import '../widgets/payment_empty_view.dart';
import '../widgets/payment_primary_button.dart';
import '../widgets/profile_sub_header.dart';

class PaymentMethodsScreen extends StatelessWidget {
  final bool isSelectionMode;
  const PaymentMethodsScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentMethodsCubit(),
      child: _PaymentBody(isSelectionMode: isSelectionMode),
    );
  }
}

class _PaymentBody extends StatelessWidget {
  final bool isSelectionMode;
  const _PaymentBody({required this.isSelectionMode});

  void _openAddCard(BuildContext context) {
    context.push(AppRoutes.addCard);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
      builder: (context, state) {
        final isEmpty = !state.loading && state.cards.isEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: PostAuthGradientBackground(
            child: Column(
              children: [
                ProfileSubHeader(title: AppStrings.paymentMethodsTitle),
                Expanded(
                  child: state.loading
                      ? const AppLoader()
                      : isEmpty
                          ? const PaymentEmptyView()
                          : PaymentCardList(
                              cards: state.cards,
                              onAdd: () => _openAddCard(context),
                              isSelectionMode: isSelectionMode,
                            ),
                ),
                if (isEmpty)
                  FlowScreenFooter(
                    child: PaymentPrimaryButton(
                      label: AppStrings.btnAddCard,
                      onTap: () => _openAddCard(context),
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
