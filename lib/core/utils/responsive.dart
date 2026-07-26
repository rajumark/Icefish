import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

class Responsive {
  static const double compact = 600;
  static const double medium = 840;

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compact) return ScreenSize.compact;
    if (width < medium) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static double getWidth(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double getHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isCompact(BuildContext context) => getScreenSize(context) == ScreenSize.compact;
  static bool isMedium(BuildContext context) => getScreenSize(context) == ScreenSize.medium;
  static bool isExpanded(BuildContext context) => getScreenSize(context) == ScreenSize.expanded;

  static int gridColumns(BuildContext context) {
    final width = getWidth(context);
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  static double contentPadding(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.compact: return 12;
      case ScreenSize.medium: return 20;
      case ScreenSize.expanded: return 24;
    }
  }

  static double cardSpacing(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.compact: return 8;
      case ScreenSize.medium: return 12;
      case ScreenSize.expanded: return 16;
    }
  }
}
