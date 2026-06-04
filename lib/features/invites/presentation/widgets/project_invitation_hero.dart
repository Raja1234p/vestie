import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vestie/core/constants/app_assets.dart';

class ProjectInvitationHero extends StatelessWidget {
  const ProjectInvitationHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        AppAssets.projectInvitationHero,
        width: 150.w,
        height: 150.w,
        fit: BoxFit.contain,
      ),
    );
  }
}
