import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_info_notice.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../../../../core/widgets/common/post_auth_gradient_background.dart';
import '../../../../core/widgets/common/post_auth_header.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late final TextEditingController _headingController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _headingController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    PostAuthHeader(
                      title: AppStrings.createAnnouncementTitle,
                      leading: GestureDetector(
                        onTap: () => context.pop(),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.grey1100,
                          size: 22.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    AppTextField(
                      label: AppStrings.announcementHeadingLabel,
                      hint: AppStrings.announcementHeadingHint,
                      controller: _headingController,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 18.h),
                    AppTextField(
                      label: AppStrings.announcementContentLabel,
                      hint: AppStrings.announcementContentHint,
                      controller: _contentController,
                      textInputAction: TextInputAction.newline,
                      minLines: 5,
                      maxLines: 5,
                    ),
                    SizedBox(height: 22.h),
                    const AppInfoNotice(text: AppStrings.announcementAutoRemoveNote),
                    SizedBox(height: 32.h),
                    AppButton(
                      text: AppStrings.btnCreateAnnouncement,
                      onPressed: () => context.pop(),
                      useGradient: false,
                      hasShadow: false,
                      color: AppColors.grey1200,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
