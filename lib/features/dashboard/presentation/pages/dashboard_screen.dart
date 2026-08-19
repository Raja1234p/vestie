import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/features/notifications/presentation/cubit/notification_unread_cubit.dart';
import 'package:vestie/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:vestie/user/features/vff/presentation/cubit/vff_pending_cubit.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_amount_sheet.dart';
import 'package:vestie/user/features/discover/presentation/pages/discover_screen.dart';
import 'package:vestie/user/features/home/presentation/pages/home_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import 'package:vestie/features/wallet/presentation/pages/wallet_screen.dart';
import '../cubit/nav_cubit.dart';
import '../models/dashboard_shell_args.dart';
import '../../../../core/realtime/projects_signalr_service.dart';
import '../../../../core/realtime/wallet_signalr_service.dart';
import '../../../../core/services/fcm_push_service.dart';
import '../../../../core/services/bank_accounts_prefetch.dart';
import '../../../../core/services/payment_methods_prefetch.dart';
import '../../../../core/services/wallet_prefetch.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Root shell for the main app — holds all bottom-nav tabs via IndexedStack.
class DashboardScreen extends StatefulWidget {
  final DashboardShellArgs shellArgs;

  const DashboardScreen({
    super.key,
    this.shellArgs = const DashboardShellArgs(),
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();

  /// Only reset a tab subtree when that tab's reload flag is set — avoids an
  /// extra Home fetch when only [DashboardShellArgs.reloadDiscoverProjectList]
  /// is true (e.g. leave project after discover join).
  static Key homeTabKey(DashboardShellArgs args) {
    if (args.reloadHomeProjectList) {
      return ValueKey('home-reload-${args.navigationMark}');
    }
    return const ValueKey('home');
  }

  static Key discoverTabKey(DashboardShellArgs args) {
    if (args.reloadDiscoverProjectList) {
      return ValueKey('discover-reload-${args.navigationMark}');
    }
    return const ValueKey('discover');
  }

  static Key walletTabKey(DashboardShellArgs args) {
    if (args.reloadWallet) {
      return ValueKey('wallet-reload-${args.navigationMark}');
    }
    return const ValueKey('wallet');
  }
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PaymentMethodsPrefetch.warmIfNeeded();
      BankAccountsPrefetch.warmIfNeeded();
      WalletPrefetch.warmIfNeeded();
      await FcmPushService.syncDeviceToken();
      if (mounted) {
        unawaited(context.read<NotificationUnreadCubit>().refresh());
        unawaited(context.read<VffPendingCubit>().refresh());
      }
      unawaited(_connectRealtimeHubsWhenReady());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    unawaited(context.read<NotificationUnreadCubit>().refresh());
    unawaited(context.read<VffPendingCubit>().refresh());
  }

  /// SignalR negotiate can lag on cold start — run after REST prefetch begins.
  Future<void> _connectRealtimeHubsWhenReady() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await Future.wait([
      ProjectsSignalRService.instance.connectIfLoggedIn(),
      WalletSignalRService.instance.connectIfLoggedIn(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final shellArgs = widget.shellArgs;
    return BlocProvider(
      create: (_) => NavCubit(initialIndex: shellArgs.initialTabIndex),
      child: _WalletShellReloadGate(
        reloadWallet: shellArgs.reloadWallet,
        child: BlocBuilder<NavCubit, int>(
          builder: (context, index) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: PostAuthGradientBackground(
                child: IndexedStack(
                  index: index,
                  children: [
                    HomeScreen(
                      key: DashboardScreen.homeTabKey(shellArgs),
                      activate: index == 0,
                      reloadHomeProjectList: shellArgs.reloadHomeProjectList,
                    ),
                    DiscoverScreen(
                      key: DashboardScreen.discoverTabKey(shellArgs),
                      activate: index == 1,
                      reloadDiscoverProjectList:
                          shellArgs.reloadDiscoverProjectList,
                    ),
                    const _PlaceholderTab(),
                    WalletScreen(
                      key: DashboardScreen.walletTabKey(shellArgs),
                      activate: index == 3,
                    ),
                    ProfileScreen(activate: index == 4),
                  ],
                ),
              ),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: index,
                onTap: (i) {
                  if (i == 2) {
                    showCreateProjectAmountSheet(context);
                  } else {
                    context.read<NavCubit>().selectTab(i);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Refetches wallet into [WalletCubit] after deposit/withdraw success navigation.
class _WalletShellReloadGate extends StatefulWidget {
  const _WalletShellReloadGate({
    required this.reloadWallet,
    required this.child,
  });

  final bool reloadWallet;
  final Widget child;

  @override
  State<_WalletShellReloadGate> createState() => _WalletShellReloadGateState();
}

class _WalletShellReloadGateState extends State<_WalletShellReloadGate> {
  @override
  void initState() {
    super.initState();
    if (!widget.reloadWallet) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletCubit>().load(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Placeholder for the center nav slot (Add opens sheet, not this tab).
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(AppStrings.navAdd, style: AppTextStyles.bodyLarge),
    );
  }
}
