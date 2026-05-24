import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/core/di/service_locator.dart';

import '../cubit/user_vff_incoming_request_list_cubit.dart';
import '../widgets/lists/user_vff_vff_requests_scaffold.dart';

/// **Flow: Hub “See all” → VFF Requests** — scrolls every inbound request.
final class UserVffVffRequestsScreen extends StatelessWidget {
  const UserVffVffRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;
    return BlocProvider(
      create: (_) => UserVffIncomingRequestListCubit(
        getVffReceivedInboxUseCase: sl.getVffReceivedInboxUseCase,
        acceptVffRequestUseCase: sl.acceptVffRequestUseCase,
        declineVffRequestUseCase: sl.declineVffRequestUseCase,
        listMyVffsUseCase: sl.listMyVffsUseCase,
      ),
      child: const UserVffVffRequestsScaffold(),
    );
  }
}
