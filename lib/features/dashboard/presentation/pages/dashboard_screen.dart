import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../discover/presentation/pages/discover_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../cubit/nav_cubit.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Root shell for the main app — holds all bottom-nav tabs via IndexedStack.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _tabs = [
    HomeScreen(),
    DiscoverScreen(),
    _PlaceholderTab(label: 'Add'),
    _PlaceholderTab(label: 'Wallet'),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: BlocBuilder<NavCubit, int>(
        builder: (context, index) {
          return Scaffold(
            body: IndexedStack(index: index, children: _tabs),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: index,
              onTap: (i) {
                if (i == 2) {
                  // Add tab → open Create Project wizard
                  context.push(AppRoutes.createProjectAmount);
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

/// Placeholder for tabs not yet implemented.
class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
