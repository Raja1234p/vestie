import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_strings.dart';
import '../../stripe/stripe_hosted_onboarding_launcher.dart';
import '../../utils/logger.dart';
import '../../theme/app_colors.dart';
import '../text/app_text.dart';
import 'app_back_button.dart';
import 'app_button.dart';
import 'app_loader.dart';
import 'app_shimmer.dart';
import 'post_auth_gradient_background.dart';
import 'post_auth_header.dart';

/// Stripe hosted Connect onboarding in the system browser.
///
/// Return paths (backend must redirect HTTPS → `vestie://`):
/// - KYC: `vestie://kyc/complete`, `vestie://kyc/refresh`
/// - Bank: `vestie://bank/return`, `vestie://bank/refresh`
///
/// [FlutterWebAuth2] closes the Custom Tab on redirect; [AppLinks] handles the
/// same URIs when the app is resumed or opened from a cold start.
class StripeBrowserOnboardingScreen extends StatefulWidget {
  final String title;
  final String urlMissingMessage;
  final String bodyMessage;
  final Future<String?> Function() resolveOnboardingUrl;
  final bool Function(String? url) isReturnUrl;
  final bool Function(String? url) isRefreshUrl;
  final Future<void> Function() onReturnUrl;
  final Future<void> Function({bool silent}) onManualCheck;
  final VoidCallback onCancel;
  final VoidCallback? onImmediateSuccess;
  final String httpsCompletionPath;

  const StripeBrowserOnboardingScreen({
    super.key,
    required this.title,
    required this.urlMissingMessage,
    required this.bodyMessage,
    required this.resolveOnboardingUrl,
    required this.isReturnUrl,
    required this.isRefreshUrl,
    required this.onReturnUrl,
    required this.onManualCheck,
    required this.onCancel,
    this.onImmediateSuccess,
    required this.httpsCompletionPath,
  });

  @override
  State<StripeBrowserOnboardingScreen> createState() =>
      _StripeBrowserOnboardingScreenState();
}

class _StripeBrowserOnboardingScreenState
    extends State<StripeBrowserOnboardingScreen>
    with WidgetsBindingObserver {
  static const _logTag = 'StripeOnboarding';

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  bool _bootstrapping = true;
  bool _handlingReturn = false;
  bool _awaitingManualReturn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _linkSub = _appLinks.uriLinkStream.listen(_onDeepLink);
    unawaited(_handleColdStartLink());
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  /// App opened from `vestie://…` while not running (backend sample pattern).
  Future<void> _handleColdStartLink() async {
    try {
      final uri = await _appLinks.getInitialLink().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (uri != null && mounted) _onDeepLink(uri);
    } catch (e, st) {
      AppLogger.error(
        'getInitialLink failed',
        error: e,
        stackTrace: st,
        name: _logTag,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_linkSub?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLogger.debug(
      'lifecycle=$state awaitingManual=$_awaitingManualReturn',
      name: _logTag,
    );
    if (state == AppLifecycleState.resumed &&
        _awaitingManualReturn &&
        !_handlingReturn &&
        !_bootstrapping) {
      AppLogger.info('App resumed — silent KYC status check', name: _logTag);
      unawaited(widget.onManualCheck(silent: true));
    }
  }

  void _onDeepLink(Uri uri) {
    AppLogger.info('Deep link: $uri', name: _logTag);
    _dispatchRedirect(uri.toString());
  }

  void _dispatchRedirect(String? url) {
    if (url == null || url.isEmpty) return;
    if (widget.isRefreshUrl(url)) {
      AppLogger.info(
        'Matched refresh URL (Stripe "Return to …" / link expired) — starting new session',
        name: _logTag,
      );
      unawaited(_runStripeSession());
      return;
    }
    if (widget.isReturnUrl(url)) {
      AppLogger.info('Matched return URL — checking KYC status', name: _logTag);
      unawaited(_onReturnLink());
      return;
    }
    AppLogger.error(
      'Redirect URL did not match expected return/refresh paths: $url',
      name: _logTag,
    );
  }

  Future<void> _bootstrap() async {
    AppLogger.info('KYC/browser onboarding bootstrap start', name: _logTag);
    setState(() {
      _bootstrapping = true;
      _error = null;
      _awaitingManualReturn = false;
    });
    try {
      final url = await widget.resolveOnboardingUrl();
      if (!mounted) return;
      if (url == null) {
        widget.onImmediateSuccess?.call();
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
      setState(() => _bootstrapping = false);
      AppLogger.info(
        'POST /kyc/start OK — opening Stripe session',
        name: _logTag,
      );
      await _runStripeSession(initialUrl: trimmed);
    } catch (e, st) {
      AppLogger.error(
        'Bootstrap failed',
        error: e,
        stackTrace: st,
        name: _logTag,
      );
      if (!mounted) return;
      setState(() {
        _bootstrapping = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _runStripeSession({String? initialUrl}) async {
    final url = initialUrl ?? (await widget.resolveOnboardingUrl())?.trim();
    if (!mounted || url == null || url.isEmpty) return;

    AppLogger.info(
      initialUrl != null
          ? 'Stripe session start (existing onboarding link)'
          : 'Stripe session start (new POST /kyc/start)',
      name: _logTag,
    );

    setState(() {
      _awaitingManualReturn = false;
      _error = null;
    });

    final callbackUrl = await StripeHostedOnboardingLauncher.openAndWaitForRedirect(
      url,
      httpsCompletionPath: widget.httpsCompletionPath,
    );

    if (!mounted) return;

    if (callbackUrl != null) {
      _dispatchRedirect(callbackUrl);
      return;
    }

    AppLogger.info(
      'No callback URL — show manual "Return to app" UI '
      '(user may have closed tab or Return hit a 404 page)',
      name: _logTag,
    );
    setState(() => _awaitingManualReturn = true);
  }

  Future<void> _onReturnLink() async {
    if (_handlingReturn) return;
    setState(() {
      _handlingReturn = true;
      _awaitingManualReturn = false;
    });
    try {
      await widget.onReturnUrl();
    } finally {
      if (mounted) setState(() => _handlingReturn = false);
    }
  }

  Future<void> _runManualCheck({bool silent = false}) async {
    if (_handlingReturn) return;
    setState(() => _handlingReturn = true);
    try {
      await widget.onManualCheck(silent: silent);
    } finally {
      if (mounted) setState(() => _handlingReturn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_handlingReturn,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_handlingReturn) widget.onCancel();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PostAuthGradientBackground(
          child: Column(
            children: [
              PostAuthHeader(
                title: widget.title,
                leading: IgnorePointer(
                  ignoring: _handlingReturn,
                  child: AppBackButton(
                    onPressed: widget.onCancel,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(child: _buildBody()),
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
        child: StripeOnboardingShimmer(),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            _awaitingManualReturn
                ? AppStrings.stripeBrowserOnboardingReturnHint
                : widget.bodyMessage,
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              height: 1.45,
              color: AppColors.grey800,
            ),
          ),
          if (_handlingReturn) ...[
            SizedBox(height: 32.h),
            const AppLoader(),
          ] else ...[
            SizedBox(height: 24.h),
            AppButton(
              text: AppStrings.stripeBrowserOnboardingReturnToApp,
              onPressed: () => _runManualCheck(),
            ),
            SizedBox(height: 12.h),
            AppButton(
              text: AppStrings.stripeBrowserOnboardingOpenAgain,
              isSecondary: true,
              onPressed: () => _runStripeSession(),
            ),
          ],
        ],
      ),
    );
  }
}
