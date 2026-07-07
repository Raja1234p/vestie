import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vestie/core/constants/app_assets.dart';
import 'package:vestie/core/constants/app_strings.dart';
import 'package:vestie/core/theme/app_colors.dart';
import 'package:vestie/core/utils/project_gallery_image_urls.dart';
import 'package:vestie/core/widgets/common/app_button.dart';
import 'package:vestie/core/widgets/common/app_network_image.dart';
import 'package:vestie/core/widgets/common/app_svg_icon.dart';
import 'package:vestie/core/widgets/common/flow_screen_footer.dart';
import 'package:vestie/features/projects/domain/entities/project_image_entity.dart';

/// Full-screen blurred gallery for project images (Figma view-images sheet).
class ProjectImagesViewer {
  ProjectImagesViewer._();

  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    if (imageUrls.isEmpty) return Future.value();
    final start = initialIndex.clamp(0, imageUrls.length - 1);

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppStrings.btnClose,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ProjectImagesViewerBody(
          imageUrls: imageUrls,
          initialIndex: start,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Future<void> openGallery(
    BuildContext context, {
    String? coverImageUrl,
    List<ProjectImageEntity> images = const [],
  }) {
    final urls = ProjectGalleryImageUrls.resolve(
      coverImageUrl: coverImageUrl,
      images: images,
    );
    if (urls.isEmpty) return Future.value();
    return show(
      context,
      imageUrls: urls,
      initialIndex: ProjectGalleryImageUrls.initialIndex(urls, coverImageUrl),
    );
  }
}

class _ProjectImagesViewerBody extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ProjectImagesViewerBody({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_ProjectImagesViewerBody> createState() =>
      _ProjectImagesViewerBodyState();
}

class _ProjectImagesViewerBodyState extends State<_ProjectImagesViewerBody> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _hasMultiple => widget.imageUrls.length > 1;

  void _close() => Navigator.of(context).pop();

  void _goToPage(int index) {
    if (index < 0 || index >= widget.imageUrls.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = screenHeight * 0.44;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: widget.imageUrls.length,
                          onPageChanged: (index) =>
                              setState(() => _currentIndex = index),
                          itemBuilder: (context, index) {
                            return AppNetworkImage(
                              imageUrl: widget.imageUrls[index],
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        if (_hasMultiple) ...[
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _GalleryNavButton(
                                    assetPath: AppAssets.galleryArrowLeft,
                                    onPressed: _currentIndex > 0
                                        ? () => _goToPage(_currentIndex - 1)
                                        : null,
                                  ),
                                  _GalleryNavButton(
                                    assetPath: AppAssets.galleryArrowRight,
                                    onPressed:
                                        _currentIndex <
                                            widget.imageUrls.length - 1
                                        ? () => _goToPage(_currentIndex + 1)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 14.h,
                            child: _GalleryPageIndicator(
                              count: widget.imageUrls.length,
                              activeIndex: _currentIndex,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              FlowScreenFooter(
                child: AppButton(
                  text: AppStrings.btnClose,
                  onPressed: _close,
                  isSecondary: true,
                  useGradient: false,
                  hasShadow: false,
                  borderRadius: 14.r,
                  height: 52.h,
                  secondaryFillColor: AppColors.surface,
                  secondaryBorderColor: AppColors.surface,
                  secondaryLabelColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GalleryNavButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onPressed;

  const _GalleryNavButton({required this.assetPath, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44.w,
          height: 44.w,
          child: Center(
            child: AppSvgIcon(
              assetPath: assetPath,
              size: 24.w,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryPageIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _GalleryPageIndicator({
    required this.count,
    required this.activeIndex,
  });

  static const Color _activeColor = Color(0xFF000000);
  static final Color _inactiveColor = Colors.black.withValues(alpha: 0.4);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 26.w : 8.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: active ? _activeColor : _inactiveColor,
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
        );
      }),
    );
  }
}
