import 'package:flutter/foundation.dart';

class Device {
  static bool get isWeb => kIsWeb;

  static bool get isDesktop =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
                defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.linux);

  static bool get isMobile =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS);

  static bool get isTablet => isMobile;
}
