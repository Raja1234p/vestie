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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: PostAuthGradientBackground(
              child: IndexedStack(
                index: index,
                children: [
                  HomeScreen(
                    key: ValueKey(
                      'home-${shellArgs.reloadHomeProjectList}-${shellArgs.navigationMark}',
                    ),
                    reloadHomeProjectList: shellArgs.reloadHomeProjectList,
                  ),
                  DiscoverScreen(
                    key: ValueKey(
                      'discover-${shellArgs.reloadDiscoverProjectList}-${shellArgs.navigationMark}',
                    ),
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
