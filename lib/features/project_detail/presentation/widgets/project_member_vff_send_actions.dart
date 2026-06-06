import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vestie/features/project_detail/domain/entities/member_entity.dart';
import 'package:vestie/features/projects/presentation/bloc/project_detail_bloc.dart';

/// Dispatches in-place VFF send from project detail member lists.
void sendMemberVffFromProjectDetail(
  BuildContext context, {
  required MemberEntity member,
}) {
  context.read<ProjectDetailBloc>().add(
    SendMemberVffRequestEvent(member: member),
  );
}
