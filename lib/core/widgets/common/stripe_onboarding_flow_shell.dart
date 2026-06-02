import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_back_button.dart';
import 'app_shimmer.dart';
import 'post_auth_gradient_background.dart';
import 'post_auth_header.dart';
import 'stripe_onboarding_web_view.dart';

/// Shared shell for KYC / bank Stripe onboarding screens.
class StripeOnboardingFlowShell extends StatefulWidget {
  final String title;
  final String urlMissingMessage;
  final Future<String?> Function() resolveOnboardingUrl;
  final bool Function(String? url) isCompletionUrl;
  final bool Function(String? url)? isRefreshUrl;
  /// Called after the return URL redirect when [onReturnUrlReached] is null.
  final VoidCallback? onFlowComplete;

  /// When set, called instead of [onFlowComplete] after the return URL redirect
  /// (e.g. verify KYC status before popping the route).
  final Future<void> Function()? onReturnUrlReached;
  final VoidCallback onCancel;

  /// When [resolveOnboardingUrl] returns null without error (e.g. bank already linked).
  final VoidCallback? onImmediateSuccess;

  const StripeOnboardingFlowShell({
    super.key,
    required this.title,
    required this.urlMissingMessage,
    required this.resolveOnboardingUrl,
    required this.isCompletionUrl,
    this.onFlowComplete,
    required this.onCancel,
    this.isRefreshUrl,
    this.onReturnUrlReached,
    this.onImmediateSuccess,
  }) : assert(
          onReturnUrlReached != null || onFlowComplete != null,
          'Provide onReturnUrlReached or onFlowComplete',
        );

  @override
  State<StripeOnboardingFlowShell> createState() =>
      _StripeOnboardingFlowShellState();
}

class _StripeOnboardingFlowShellState extends State<StripeOnboardingFlowShell> {
  final _webViewKey = GlobalKey<StripeOnboardingWebViewState>();

  bool _bootstrapping = true;
  bool _returnUrlReceived = false;
  bool _handlingReturnUrl = false;
  String? _onboardingUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() {
      _bootstrapping = true;
      _error = null;
    });

    try {
      final url = await widget.resolveOnboardingUrl();
      if (!mounted) return;

      if (url == null) {
        if (widget.onImmediateSuccess != null) {
          widget.onImmediateSuccess!();
        } else {
          setState(() {
            _bootstrapping = false;
            _error = widget.urlMissingMessage;
          });
        }
        return;
      }

      final trimmed = url.trim();
      if (trimmed.isEmpty) {
        setState(() {
          _bootstrapping = false;
          _error = widget.urlMissingMessage;
        });
        return;
      }

      setState(() {
        _bootstrapping = false;
        _onboardingUrl = trimmed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bootstrapping = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _onStripeRefresh() async {
    if (_bootstrapping) return;
    final previousUrl = _onboardingUrl;
    await _bootstrap();
    if (!mounted) return;
    final nextUrl = _onboardingUrl;
    if (nextUrl != null &&
        nextUrl.isNotEmpty &&
        nextUrl != previousUrl &&
        _webViewKey.currentState != null) {
      await _webViewKey.currentState!.reloadOnboarding(nextUrl);
    }
  }

  Future<void> _onWebViewReturnUrl() async {
    if (_returnUrlReceived || _handlingReturnUrl) return;
    _returnUrlReceived = true;
    _handlingReturnUrl = true;
    if (mounted) setState(() {});

    try {
      if (widget.onReturnUrlReached != null) {
        await widget.onReturnUrlReached!();
      } else {
        widget.onFlowComplete?.call();
      }
    } finally {
      _handlingReturnUrl = false;
    }
  }

  Future<void> _onBackPressed() async {
    if (_returnUrlReceived || _handlingReturnUrl) return;

    if (_onboardingUrl == null) {
      widget.onCancel();
      return;
    }
    final shouldPopRoute = await _webViewKey.currentState?.handleBack() ?? true;
    if (shouldPopRoute && mounted) {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWebView = _onboardingUrl != null;
    final blockPop = hasWebView || _handlingReturnUrl;

    return PopScope(
      canPop: !blockPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PostAuthGradientBackground(
          child: Column(
            children: [
              PostAuthHeader(
                title: widget.title,
                leading: IgnorePointer(
                  ignoring: _handlingReturnUrl,
                  child: AppBackButton(
                    onPressed: _onBackPressed,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: _buildBody(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_bootstrapping) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: KycWebViewShimmer(),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: AppColors.grey800,
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: _bootstrap,
                child: const Text(AppStrings.btnRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (_onboardingUrl == null) {
      return const SizedBox.shrink();
    }
    return StripeOnboardingWebView(
      key: _webViewKey,
      initialUrl: _onboardingUrl!,
      isCompletionUrl: widget.isCompletionUrl,
      isRefreshUrl: widget.isRefreshUrl,
      onRefresh: _onStripeRefresh,
      onComplete: _onWebViewReturnUrl,
    );
  }
}
