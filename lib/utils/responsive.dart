import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  //static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1200;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return ScreenSize.desktop;
  //  if (width >= tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) => of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) => isMobile(context);
  static bool isDesktop(BuildContext context) => of(context) == ScreenSize.desktop;
}
