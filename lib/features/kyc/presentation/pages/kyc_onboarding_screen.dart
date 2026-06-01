import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_shimmer.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/widgets/text/app_text.dart';
import 'package:vestie/features/kyc/domain/kyc_status_cache.dart';
import 'package:vestie/features/kyc/presentation/constants/kyc_flow_constants.dart';

/// Stripe Connect Express onboarding in an in-app WebView (`POST /kyc/start`).
class KycOnboardingScreen extends StatefulWidget {
  const KycOnboardingScreen({super.key});

  @override
  State<KycOnboardingScreen> createState() => _KycOnboardingScreenState();
}

class _KycOnboardingScreenState extends State<KycOnboardingScreen> {
  WebViewController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startOnboarding());
  }

  Future<void> _startOnboarding() async {
    final result = await ServiceLocator.instance.startKycUseCase(
      country: 'US',
      refreshUrl: KycFlowConstants.refreshUrl,
      returnUrl: KycFlowConstants.returnUrl,
    );
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = FailureMapper.userMessage(failure);
      }),
      (start) {
        final url = start.onboardingUrl?.trim();
        if (url == null || url.isEmpty) {
          setState(() {
            _loading = false;
            _error = AppStrings.kycOnboardingUrlMissing;
          });
          return;
        }
        _openWebView(url);
      },
    );
  }

  void _openWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) => _onUrl(change.url),
          onPageFinished: (pageUrl) => _onUrl(pageUrl),
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controller = controller;
      _loading = false;
      _error = null;
    });
  }

  void _onUrl(String? url) {
    if (!KycFlowConstants.isCompletionOrRefreshUrl(url)) return;
    KycStatusCache.clear();
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            PostAuthHeader(
              title: AppStrings.kycOnboardingTitle,
              leading: AppBackButton(
                onPressed: () => context.pop(false),
                color: AppColors.textPrimary,
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
    );
  }

  Widget _buildBody() {
    if (_loading) {
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
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _startOnboarding();
                },
                child: Text(AppStrings.btnRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller == null) {
      return const SizedBox.shrink();
    }
    return WebViewWidget(controller: _controller!);
  }
}
