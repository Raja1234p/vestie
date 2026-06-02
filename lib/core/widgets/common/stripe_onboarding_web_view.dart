import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_shimmer.dart';

/// In-app Stripe Connect / bank onboarding WebView.
///
/// Keeps [KycWebViewShimmer] until the first page finishes loading (fully visible).
/// [handleBack] walks WebView history before the route should pop.
///
/// Return / refresh redirects are detected in [NavigationDelegate.onNavigationRequest]
/// only (not [onPageFinished] / [onUrlChange]) to avoid false completion on back.
class StripeOnboardingWebView extends StatefulWidget {
  final String initialUrl;
  final bool Function(String? url) isCompletionUrl;
  final bool Function(String? url)? isRefreshUrl;
  final VoidCallback onComplete;
  final VoidCallback? onRefresh;

  const StripeOnboardingWebView({
    super.key,
    required this.initialUrl,
    required this.isCompletionUrl,
    required this.onComplete,
    this.isRefreshUrl,
    this.onRefresh,
  });

  @override
  StripeOnboardingWebViewState createState() => StripeOnboardingWebViewState();
}

class StripeOnboardingWebViewState extends State<StripeOnboardingWebView> {
  late final WebViewController _controller;
  bool _firstPageLoaded = false;
  bool _flowCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _onFirstPageLoaded(),
          onNavigationRequest: (request) {
            final decision = _navigationDecision(request.url);
            if (decision != null) return decision;
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  /// Loads a new Stripe session (e.g. after `refreshUrl` redirect).
  Future<void> reloadOnboarding(String url) async {
    _flowCompleted = false;
    if (mounted) {
      setState(() => _firstPageLoaded = false);
    }
    await _controller.loadRequest(Uri.parse(url));
  }

  /// Returns `true` when the hosting route should pop (no WebView history).
  Future<bool> handleBack() async {
    if (_flowCompleted) return false;
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  void _onFirstPageLoaded() {
    if (!mounted || _firstPageLoaded) return;
    setState(() => _firstPageLoaded = true);
  }

  NavigationDecision? _navigationDecision(String? url) {
    if (_isRefresh(url)) {
      widget.onRefresh?.call();
      return NavigationDecision.prevent;
    }
    if (widget.isCompletionUrl(url)) {
      _tryComplete();
      return NavigationDecision.prevent;
    }
    return null;
  }

  bool _isRefresh(String? url) {
    final checker = widget.isRefreshUrl;
    return checker != null && checker(url);
  }

  void _tryComplete() {
    if (_flowCompleted) return;
    _flowCompleted = true;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (!_firstPageLoaded)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: KycWebViewShimmer(),
              ),
            ),
          ),
      ],
    );
  }
}
