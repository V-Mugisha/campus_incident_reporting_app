/// Shared app strings and design tokens (spacing, radius, sizes).
/// Screens should reference these instead of hard-coding values.
class AppStrings {
  AppStrings._();

  static const String appName = 'CampusCare';
  static const String tagline = 'Help make our campus safer.';
}

class AppSpacing {
  AppSpacing._();

  static const double screenPadding = 24;
  static const double formGap = 20;
  static const double labelGap = 8;
  static const double headerGap = 32;
}

class AppRadius {
  AppRadius._();

  static const double input = 12;
  static const double button = 16;
  static const double card = 20;
}

class AppSize {
  AppSize._();

  static const double inputHeight = 52;
  static const double buttonHeight = 54;
}

/// Extra bottom padding for scrollable tab pages so the floating nav bar
/// never covers the last item. 90 (bar + button rise) + 12 (margin) + ~26 (inset) + 16 (spacer).
const double kNavBarClearance = 144;
