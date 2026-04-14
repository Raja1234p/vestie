import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Screen properties
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get rootSize => mediaQuery.size;
  double get screenWidth => rootSize.width;
  double get screenHeight => rootSize.height;

  // Theming shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Focus utility
  void removeFocus() {
    FocusScope.of(this).unfocus();
  }
}
