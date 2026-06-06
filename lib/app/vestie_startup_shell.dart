import 'dart:async';

import 'package:flutter/material.dart';

import '../bootstrap.dart';
import '../core/constants/app_assets.dart';
import 'boot_splash_app.dart';

/// Calls [runApp] immediately, paints [BootSplashApp], then runs [AppBootstrap.run]
/// before swapping to the real app tree.
class VestieStartupShell extends StatefulWidget {
  const VestieStartupShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<VestieStartupShell> createState() => _VestieStartupShellState();
}

class _VestieStartupShellState extends State<VestieStartupShell> {
  var _bootstrapComplete = false;

  @override
  void initState() {
    super.initState();
    unawaited(_runBootstrap());
  }

  Future<void> _runBootstrap() async {
    await AppBootstrap.run();
    if (!mounted) return;
    setState(() => _bootstrapComplete = true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.splashBackground), context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapComplete) {
      return const BootSplashApp();
    }
    return widget.child;
  }
}
