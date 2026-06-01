import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/app/router/route_args/contribute_payment_picker_args.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_selection.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_method_select_row.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_primary_button.dart';

/// Pick wallet or card for contribute (wallet disabled when balance too low).
class ContributePaymentPickerScreen extends StatefulWidget {
  const ContributePaymentPickerScreen({super.key, required this.args});

  final ContributePaymentPickerArgs args;

  @override
  State<ContributePaymentPickerScreen> createState() =>
      _ContributePaymentPickerScreenState();
}

class _ContributePaymentPickerScreenState
    extends State<ContributePaymentPickerScreen> {
  List<PaymentCard> _cards = const [];
  bool _loading = true;
  String? _error;
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result =
        await ServiceLocator.instance.listPaymentMethodsUseCase(forceRefresh: true);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _loading = false;
        _error = FailureMapper.userMessage(f);
        _cards = const [];
      }),
      (cards) => setState(() {
        _loading = false;
        _cards = cards;
      }),
    );
  }

  void _selectCard(PaymentCard card) {
    context.pop(CardPaymentMethodSelection(card));
  }

  void _selectWallet() {
    if (!widget.args.walletCoversTotal) return;
    context.pop(const WalletPaymentMethodSelection());
  }

  Future<void> _addCard() async {
    final added = await context.push<bool>(AppRoutes.addCard);
    if (added == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletEnabled = widget.args.walletCoversTotal;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: AppStrings.paymentMethodsTitle,
              padding: EdgeInsets.fromLTRB(
                AppDimens.p16,
                AppDimens.v16,
                AppDimens.p16,
                AppDimens.v10,
              ),
              leading: AppBackButton(
                onPressed: context.pop,
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _loading
                  ? const PaymentCardListShimmer()
                  : _error != null
                      ? AppErrorView(
                          message: _error,
                          onRetry: _load,
                        )
                      : ListView(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                          children: [
                            for (var i = 0; i < _cards.length; i++) ...[
                              if (i > 0)
                                SizedBox(height: AppDimens.paymentMethodRowGap),
                              PaymentMethodSelectRow(
                                selected: _selectedCardId == _cards[i].id,
                                leading: SizedBox(
                                  width: 32.w,
                                  height: 32.h,
                                  child: SvgPicture.asset(
                                    _cards[i].brand == CardBrand.visa
                                        ? AppAssets.iconVisa
                                        : AppAssets.iconMastercard,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                title: _cards[i].brandName,
                                subtitle: _cards[i].maskedNumber,
                                onTap: () {
                                  setState(() => _selectedCardId = _cards[i].id);
                                  _selectCard(_cards[i]);
                                },
                              ),
                            ],
                            SizedBox(height: 16.h),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.neutral400,
                            ),
                            SizedBox(height: 16.h),
                            PaymentMethodSelectRow(
                              selected: false,
                              enabled: walletEnabled,
                              leading: SizedBox(
                                width: 32.w,
                                height: 32.h,
                                child: SvgPicture.asset(
                                  AppAssets.iconDollarCircle,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              title: AppStrings.walletTitle,
                              subtitle: walletEnabled
                                  ? widget.args.walletAmountFormatted
                                  : AppStrings.contributeWalletInsufficientSubtitle,
                              onTap: _selectWallet,
                            ),
                          ],
                        ),
            ),
            FlowScreenFooter(
              child: PaymentPrimaryButton(
                label: AppStrings.btnAddCard,
                onTap: _loading ? null : _addCard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
