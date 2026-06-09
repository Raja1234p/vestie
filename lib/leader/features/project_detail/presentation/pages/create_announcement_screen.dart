import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/validation_utils.dart';
import 'package:vestie/core/widgets/common/app_back_button.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_info_notice.dart';
import 'package:vestie/core/widgets/common/app_text_field.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_header.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/error/failure_mapper.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final String projectId;

  const CreateAnnouncementScreen({super.key, required this.projectId});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late final TextEditingController _headingController;
  late final TextEditingController _contentController;
  late final FocusNode _headingFocus;
  late final FocusNode _contentFocus;

  String? _headingError;
  String? _contentError;
  bool _submitting = false;

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
    final h = ValidationUtils.validateAnnouncementHeading(
      _headingController.text,
    );
    final c = ValidationUtils.validateAnnouncementContent(
      _contentController.text,
    );
    setState(() {
      _headingError = h;
      _contentError = c;
    });
    return h == null && c == null;
  }

  Future<void> _onSubmit() async {
    if (!_validate()) return;
    _unfocusKeyboard();
    setState(() => _submitting = true);
    final result = await ServiceLocator.instance
        .createProjectAnnouncementUseCase(
          projectId: widget.projectId,
          heading: _headingController.text.trim(),
          content: _contentController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      (f) => AppToast.showError(context, FailureMapper.userMessage(f)),
      (_) {
        AppToast.showSuccess(context, AppStrings.btnCreateAnnouncement);
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: PostAuthGradientBackground(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _unfocusKeyboard,
                behavior: HitTestBehavior.deferToChild,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: AppDimens.postAuthFlowScrollPaddingWithKeyboard(
                    context,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PostAuthHeader(
                        title: AppStrings.createAnnouncementTitle,
                        padding: EdgeInsets.fromLTRB(0, 20.h, 0, 0),
                        leading: AppBackButton(
                          onPressed: () {
                            _unfocusKeyboard();
                            context.pop();
                          },
                        ),
                      ),
                      AppTextField(
                        focusNode: _headingFocus,
                        label: AppStrings.announcementHeadingLabel,
                        hint: AppStrings.announcementHeadingHint,
                        controller: _headingController,
                        fillColor: AppColors.searchBarBg,
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
                        fillColor: AppColors.searchBarBg,
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
                      const AppInfoNotice(
                        text: AppStrings.announcementAutoRemoveNote,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FlowScreenFooter(
              child: AppButton(
                text: AppStrings.btnCreateAnnouncement,
                isLoading: _submitting,
                onPressed: _submitting ? null : _onSubmit,
                useGradient: false,
                hasShadow: false,
                color: AppColors.grey1200,
                borderRadius: 12.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
