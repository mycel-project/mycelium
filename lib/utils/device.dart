import 'dart:io';

class Device {
  static bool get isDesktop =>
  Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get isMobile =>
  Platform.isAndroid || Platform.isIOS;

  static bool get isTablet => isMobile; 
}
