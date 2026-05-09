import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/user_vff_incoming_request_list_cubit.dart';
import '../models/user_vff_hub_ui_model.dart';
import '../widgets/lists/user_vff_vff_requests_scaffold.dart';

/// **Flow: Hub “See all” → VFF Requests** — scrolls every inbound request.
final class UserVffVffRequestsScreen extends StatelessWidget {
  final List<UserVffIncomingRequestUi> rows;

  const UserVffVffRequestsScreen({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserVffIncomingRequestListCubit(rows),
      child: const UserVffVffRequestsScaffold(),
    );
  }
}
