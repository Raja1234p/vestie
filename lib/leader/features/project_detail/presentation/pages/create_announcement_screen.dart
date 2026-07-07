import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vestie/core/constants/app_dimens.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/validation_utils.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_info_notice.dart';
import 'package:vestie/core/widgets/common/app_text_field.dart';
import 'package:vestie/core/widgets/common/post_auth_gradient_background.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/core/widgets/common/post_auth_flow_sub_header.dart';
import 'package:vestie/core/di/service_locator.dart';
import 'package:vestie/core/widgets/common/app_toast.dart';
import 'package:vestie/core/error/failure_mapper.dart';

import 'package:vestie/features/project_announcements/domain/announcement_attachment_limits.dart';
import 'package:vestie/leader/features/create_project/presentation/utils/create_project_image_picker.dart';
import 'package:vestie/leader/features/project_detail/presentation/widgets/announcement_image_upload_field.dart';

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
  String? _imagePath;
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

  Future<void> _pickImage() async {
    _unfocusKeyboard();
    await CreateProjectImagePicker.showSourceSheet(
      context,
      remainingSlots: 1,
      onPicked: (paths) {
        if (paths.isEmpty || !mounted) return;
        final error = ValidationUtils.validateAnnouncementAttachmentPath(paths.first);
        if (error != null) {
          AppToast.showError(context, error);
          return;
        }
        setState(() => _imagePath = paths.first);
      },
    );
  }

  void _removeImage() {
    setState(() => _imagePath = null);
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

    final attachmentPaths = <String>[];
    final imagePath = _imagePath?.trim();
    if (imagePath != null && imagePath.isNotEmpty) {
      final attachmentError =
          ValidationUtils.validateAnnouncementAttachmentPath(imagePath);
      if (attachmentError != null) {
        AppToast.showError(context, attachmentError);
        return;
      }
      attachmentPaths.add(imagePath);
    }

    setState(() => _submitting = true);
    final result = await ServiceLocator.instance
        .createProjectAnnouncementUseCase(
          projectId: widget.projectId,
          heading: _headingController.text.trim(),
          content: _contentController.text.trim(),
          attachmentPaths: attachmentPaths,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostAuthFlowSubHeader(
              title: AppStrings.createAnnouncementTitle,
              onBack: () {
                _unfocusKeyboard();
                context.pop();
              },
            ),
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
                      AppTextField(
                        focusNode: _headingFocus,
                        label: AppStrings.announcementHeadingLabel,
                        hint: AppStrings.announcementHeadingHint,
                        controller: _headingController,
                        fillColor: AppColors.searchBarBg,
                        maxLength: AnnouncementAttachmentLimits.maxHeadingLength,
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
                        maxLength: AnnouncementAttachmentLimits.maxContentLength,
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
                      SizedBox(height: 18.h),
                      AnnouncementImageUploadField(
                        imagePath: _imagePath,
                        onTap: _pickImage,
                        onRemove: _removeImage,
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
