import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/leader/features/create_project/presentation/widgets/create_project_amount_sheet.dart';
import 'package:vestie/user/features/discover/presentation/pages/discover_screen.dart';
import 'package:vestie/user/features/home/presentation/pages/home_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../wallet/presentation/pages/wallet_screen.dart';
import '../cubit/nav_cubit.dart';
import '../models/dashboard_shell_args.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Root shell for the main app — holds all bottom-nav tabs via IndexedStack.
class DashboardScreen extends StatelessWidget {
  final DashboardShellArgs shellArgs;

  const DashboardScreen({
    super.key,
    this.shellArgs = const DashboardShellArgs(),
  });

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(initialIndex: shellArgs.initialTabIndex),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: IndexedStack(
                index: index,
                children: [
                  HomeScreen(
                    key: homeTabKey(shellArgs),
                    reloadHomeProjectList: shellArgs.reloadHomeProjectList,
                  ),
                  DiscoverScreen(
                    key: discoverTabKey(shellArgs),
                    activate: index == 1,
                    reloadDiscoverProjectList:
                        shellArgs.reloadDiscoverProjectList,
                  ),
                  const _PlaceholderTab(),
                  const WalletScreen(),
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
    );
  }
}

/// Placeholder for the center nav slot (Add opens sheet, not this tab).
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(
        AppStrings.navAdd,
        style: AppTextStyles.bodyLarge,
      ),
    );
  }
}
