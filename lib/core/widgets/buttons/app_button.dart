import 'package:flutter/material.dart';
import '../../extensions/context_extensions.dart';
import '../../constants/app_dimens.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightMd,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary 
            ? context.theme.scaffoldBackgroundColor 
            : context.colorScheme.primary,
          foregroundColor: isSecondary 
            ? context.colorScheme.primary 
            : context.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: isSecondary 
              ? BorderSide(color: context.colorScheme.primary) 
              : BorderSide.none,
          ),
          elevation: 0, // Flat design by default
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: AppDimens.iconMedium,
                width: AppDimens.iconMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary 
                      ? context.colorScheme.primary 
                      : context.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                text,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSecondary 
                      ? context.colorScheme.primary 
                      : context.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
