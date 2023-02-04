import 'package:flutter/foundation.dart';

final List<TargetPlatform> kDesktopPlatforms = [
  TargetPlatform.windows,
  TargetPlatform.macOS,
  TargetPlatform.linux
];

final List<TargetPlatform> kMobilePlatforms = [
  TargetPlatform.android,
  TargetPlatform.iOS,
];

/// Checks if the current platform is a web platform
bool isWebPlatform() => kIsWeb;

/// Checks if the current platform is a Desktop platform
bool isDesktopPlatform() => kDesktopPlatforms.contains(defaultTargetPlatform);

/// Checks if the current platform is a Mobile platform
bool isMobilePlatform() => kMobilePlatforms.contains(defaultTargetPlatform);
