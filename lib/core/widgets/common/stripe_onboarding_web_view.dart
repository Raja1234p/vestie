import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_shimmer.dart';

/// In-app Stripe Connect / bank onboarding WebView.
///
/// Keeps [KycWebViewShimmer] until the first page finishes loading (fully visible).
/// [handleBack] walks WebView history before the route should pop.
class StripeOnboardingWebView extends StatefulWidget {
  final String initialUrl;
  final bool Function(String? url) isCompletionUrl;
  final VoidCallback onComplete;

  const StripeOnboardingWebView({
    super.key,
    required this.initialUrl,
    required this.isCompletionUrl,
    required this.onComplete,
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
          onPageFinished: (url) => _onPageFinished(url),
          onUrlChange: (change) => _tryComplete(change.url),
          onNavigationRequest: (request) {
            _tryComplete(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  /// Returns `true` when the hosting route should pop (no WebView history).
  Future<bool> handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  void _onPageFinished(String url) {
    if (!mounted) return;
    setState(() => _firstPageLoaded = true);
    _tryComplete(url);
  }

  void _tryComplete(String? url) {
    if (_flowCompleted || !widget.isCompletionUrl(url)) return;
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
