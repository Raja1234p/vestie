import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/theme/app_text_styles.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_numpad.dart';
import 'package:vestie/core/widgets/common/app_text.dart';
import 'package:vestie/leader/features/create_project/domain/create_project_form.dart';
import 'package:vestie/leader/features/create_project/presentation/cubit/create_project_cubit.dart';

/// Figma “set amount” step — shared by [showCreateProjectAmountSheet] and route.
class CreateProjectAmountSheetContent extends StatelessWidget {
  const CreateProjectAmountSheetContent({
    super.key,
    required this.onFinished,
  });

  final ValueChanged<bool> onFinished;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProjectCubit, CreateProjectForm>(
      builder: (context, form) {
        final cubit = context.read<CreateProjectCubit>();
        return Material(
          color: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppDimens.v12),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.p20,
                  vertical: AppDimens.v12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => onFinished(false),
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                          AppAssets.iconCreateProjectSheetClose,
                          width: AppDimens.iconLarge,
                          height: AppDimens.iconLarge,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppDimens
                          .createProjectAmountSheetIconTitleVerticalGap,
                    ),
                    AppText(
                      AppStrings.projectAmountSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.createProjectAmountSheetTitle,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimens.v16),
              AppText(
                form.amountDigits.isEmpty
                    ? AppStrings.projectAmountEmptyDisplay
                    : form.formattedAmount,
                textAlign: TextAlign.center,
                style: AppTextStyles.createProjectAmountSheetValue,
              ),
              SizedBox(height: AppDimens.v28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.p24),
                child: AppButton(
                  text: AppStrings.btnContinue,
                  onPressed: form.amountDigits.isEmpty
                      ? null
                      : () => onFinished(true),
                ),
              ),
              SizedBox(height: AppDimens.v16),
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.r16),
                ),
                child: AppNumpad(
                  onDigit: cubit.appendAmountDigit,
                  onBackspace: cubit.removeAmountDigit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
