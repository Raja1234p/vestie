import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/app/router/app_routes.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/error/failure_mapper.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_error_view.dart';
import 'package:vestie/features/project_detail/domain/entities/project_detail_completed_outcome_extensions.dart';
import 'package:vestie/features/project_detail/presentation/navigation/open_project_from_card.dart';
import 'package:vestie/features/project_detail/presentation/mappers/closure_vote_ui_mappers.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_load_route_args.dart';
import 'package:vestie/features/success_vote/presentation/models/success_vote_outcome_route_args.dart';
import 'package:vestie/features/success_vote/presentation/pages/success_vote_outcome_screen.dart';

/// Fetches project detail, then shows [SuccessVoteOutcomeScreen] (white success layout).
class SuccessVoteOutcomeLoadScreen extends StatefulWidget {
  final SuccessVoteOutcomeLoadRouteArgs args;

  const SuccessVoteOutcomeLoadScreen({super.key, required this.args});

  @override
  State<SuccessVoteOutcomeLoadScreen> createState() =>
      _SuccessVoteOutcomeLoadScreenState();
}

class _SuccessVoteOutcomeLoadScreenState
    extends State<SuccessVoteOutcomeLoadScreen> {
  bool _loading = true;
  String? _errorMessage;
  SuccessVoteOutcomeRouteArgs? _outcomeArgs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _outcomeArgs = null;
    });

    final result =
        await ServiceLocator.instance.projectDetailRepository.getProjectDetail(
      projectId: widget.args.projectId,
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _errorMessage = FailureMapper.userMessage(failure);
      }),
      (project) {
        if (!project.showsCompletedProjectVoteOutcome) {
          setState(() => _loading = false);
          final detailArgs = projectDetailRouteArgsForDetail(project);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.replace(
              AppRoutes.investmentProjectDetail,
              extra: detailArgs,
            );
          });
          return;
        }
        setState(() {
          _loading = false;
          _outcomeArgs = successVoteOutcomeRouteArgsFromProjectDetail(project);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_outcomeArgs != null) {
      return SuccessVoteOutcomeScreen(args: _outcomeArgs!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _OutcomeLoadBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 4.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : AppErrorView(
                          message: _errorMessage,
                          onRetry: _load,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeLoadBackground extends StatelessWidget {
  const _OutcomeLoadBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: ColoredBox(color: Colors.white)),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image(
            image: AssetImage(AppAssets.successScreenBackground),
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
