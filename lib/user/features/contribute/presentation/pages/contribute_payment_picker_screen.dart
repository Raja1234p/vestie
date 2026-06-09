import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vestie/app/router/route_args/contribute_payment_picker_args.dart';
import 'package:vestie/features/payment_methods/presentation/add_card_stripe_launcher.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/services/payment_methods_prefetch.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/features/payment_methods/domain/payment_methods_cache.dart';
import 'package:vestie/features/profile/domain/entities/payment_card.dart';
import 'package:vestie/features/profile/domain/entities/payment_method_selection.dart';
import 'package:vestie/features/profile/domain/payment_source_preference.dart';
import 'package:vestie/features/profile/presentation/widgets/payment_card_brand_icon.dart';
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
  bool _walletSelected = false;

  @override
  void initState() {
    super.initState();
    final cached = PaymentMethodsCache.value;
    if (cached != null) {
      _cards = cached;
      _loading = false;
      _syncInitialSelection();
      unawaited(PaymentMethodsPrefetch.refresh().then((_) => _reloadFromCache()));
    } else {
      _load();
    }
  }

  Future<void> _reloadFromCache() async {
    final cached = PaymentMethodsCache.value;
    if (!mounted || cached == null) return;
    setState(() {
      _cards = cached;
      _syncInitialSelection();
    });
  }

  void _syncInitialSelection() {
    final args = widget.args;
    if (args.initialPayFromWallet && args.walletCoversTotal) {
      _walletSelected = true;
      _selectedCardId = null;
      return;
    }
    if (args.initialSelectedCardId != null &&
        _cards.any((c) => c.id == args.initialSelectedCardId)) {
      _walletSelected = false;
      _selectedCardId = args.initialSelectedCardId;
      return;
    }
    final pref = PaymentSourcePreference.resolve(
      walletBalance: args.walletBalance,
      requiredTotal: args.requiredTotal,
      cards: _cards,
    );
    _walletSelected = pref.payFromWallet;
    _selectedCardId = pref.card?.id;
  }

  Future<void> _load() async {
    setState(() {
      if (_cards.isEmpty) {
        _loading = true;
      }
      _error = null;
    });

    await PaymentMethodsPrefetch.warmIfNeeded();
    if (!mounted) return;

    final cached = PaymentMethodsCache.value;
    if (cached == null) {
      setState(() {
        _loading = false;
        _error = AppStrings.paymentMethodsLoadFailed;
      });
      return;
    }

    setState(() {
      _loading = false;
      _cards = cached;
      _syncInitialSelection();
    });
  }

  void _selectCard(PaymentCard card) {
    context.pop(CardPaymentMethodSelection(card));
  }

  void _selectWallet() {
    if (!widget.args.walletCoversTotal) return;
    context.pop(const WalletPaymentMethodSelection());
  }

  Future<void> _addCard() async {
    final card = await AddCardStripeLauncher.launch(context);
    if (card != null && mounted) {
      await _reloadFromCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletEnabled = widget.args.walletCoversTotal;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.paymentMethodsTitle,
              onBack: context.pop,
            ),
            Expanded(
              child: _loading
                  ? const PaymentCardListShimmer()
                  : _error != null
                  ? AppErrorView(message: _error, onRetry: _load)
                  : ListView(
                      padding: FlowScreenFooterInsets.listPadding(context),
                      children: [
                        for (var i = 0; i < _cards.length; i++) ...[
                          if (i > 0)
                            SizedBox(height: AppDimens.paymentMethodRowGap),
                          PaymentMethodSelectRow(
                            selected:
                                !_walletSelected &&
                                _selectedCardId == _cards[i].id,
                            leading: SizedBox(
                              width: 32.w,
                              height: 32.h,
                              child: PaymentCardBrandIcon(
                                brand: _cards[i].brand,
                              ),
                            ),
                            title: _cards[i].brandName,
                            subtitle: _cards[i].maskedNumber,
                            onTap: () {
                              setState(() {
                                _walletSelected = false;
                                _selectedCardId = _cards[i].id;
                              });
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
                          selected: _walletSelected && walletEnabled,
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
                          onTap: () {
                            if (!walletEnabled) return;
                            setState(() {
                              _walletSelected = true;
                              _selectedCardId = null;
                            });
                            _selectWallet();
                          },
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
