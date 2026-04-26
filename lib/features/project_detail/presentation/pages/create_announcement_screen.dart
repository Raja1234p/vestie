import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/widgets/common/app_back_button.dart';
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
  late final FocusNode _headingFocus;
  late final FocusNode _contentFocus;

  String? _headingError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController();
    _contentController = TextEditingController();
    _headingFocus = FocusNode();
    _contentFocus = FocusNode();
  }

  @override
  void dispose() {
    _headingController.dispose();
    _contentController.dispose();
    _headingFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _unfocusKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  bool _validate() {
    final h = ValidationUtils.validateAnnouncementHeading(_headingController.text);
    final c = ValidationUtils.validateAnnouncementContent(_contentController.text);
    setState(() {
      _headingError = h;
      _contentError = c;
    });
    return h == null && c == null;
  }

  void _onSubmit() {
    if (!_validate()) return;
    _unfocusKeyboard();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PostAuthGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              onTap: _unfocusKeyboard,
              behavior: HitTestBehavior.deferToChild,
              child: SingleChildScrollView(
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
                        padding: EdgeInsets.fromLTRB(0, 20.h, 0, 12.h),
                        leading: AppBackButton(
                          onPressed: () {
                            _unfocusKeyboard();
                            context.pop();
                          },
                        ),
                      ),
                      SizedBox(height: 14.h),
                      AppTextField(
                        focusNode: _headingFocus,
                        label: AppStrings.announcementHeadingLabel,
                        hint: AppStrings.announcementHeadingHint,
                        controller: _headingController,
                        textInputAction: TextInputAction.next,
                        errorText: _headingError,
                        onChanged: (_) {
                          if (_headingError != null) {
                            setState(() => _headingError = null);
                          }
                        },
                        onSubmitted: (_) => _contentFocus.requestFocus(),
                      ),
                      SizedBox(height: 18.h),
                      AppTextField(
                        focusNode: _contentFocus,
                        label: AppStrings.announcementContentLabel,
                        hint: AppStrings.announcementContentHint,
                        controller: _contentController,
                        textInputAction: TextInputAction.done,
                        minLines: 5,
                        maxLines: 5,
                        errorText: _contentError,
                        onChanged: (_) {
                          if (_contentError != null) {
                            setState(() => _contentError = null);
                          }
                        },
                        onSubmitted: (_) => _unfocusKeyboard(),
                      ),
                      SizedBox(height: 22.h),
                      const AppInfoNotice(text: AppStrings.announcementAutoRemoveNote),
                      SizedBox(height: 32.h),
                      AppButton(
                        text: AppStrings.btnCreateAnnouncement,
                        onPressed: _onSubmit,
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
      ),
    );
  }
}
