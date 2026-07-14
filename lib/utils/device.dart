import 'package:flutter/foundation.dart';
enum AppOS { android, ios, windows, macos, linux, fuchsia, unknown }
 
class Device {
  static bool get isWeb => kIsWeb;
 
  static AppOS get os {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppOS.android;
      case TargetPlatform.iOS:
        return AppOS.ios;
      case TargetPlatform.windows:
        return AppOS.windows;
      case TargetPlatform.macOS:
        return AppOS.macos;
      case TargetPlatform.linux:
        return AppOS.linux;
      case TargetPlatform.fuchsia:
        return AppOS.fuchsia;
      // ignore: unreachable_switch_default
      default:
        return AppOS.unknown;
    }
  }
 
  static bool get isMobile => os == AppOS.android || os == AppOS.ios;
  static bool get isDesktop =>
      os == AppOS.windows || os == AppOS.macos || os == AppOS.linux;
  static bool get isOtherOS => !isMobile && !isDesktop;
}
