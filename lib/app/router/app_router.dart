import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import 'app_routes.dart';
import 'route_groups/core_routes.dart';
import 'route_groups/profile_wallet_routes.dart';
import 'route_groups/project_routes.dart';

class AppRouter {
  static Widget _invalidRouteScreen() => const Scaffold(
        body: Center(child: Text(AppStrings.routeNotFound)),
      );

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      ...buildCoreRoutes(),
      ...buildProfileWalletRoutes(),
      ...buildProjectRoutes(invalidRouteScreen: _invalidRouteScreen),
    ],
    errorBuilder: (context, _) => const Scaffold(
      body: Center(child: Text(AppStrings.routeNotFound)),
    ),
  );
}

