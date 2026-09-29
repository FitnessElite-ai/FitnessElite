import 'package:flutter/material.dart';

/// Screen size break points
enum DeviceScreenType { smallPhone, standardPhone, largePhone, tablet }

class ResponsiveUtils {
  ResponsiveUtils._();

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return DeviceScreenType.smallPhone;
    } else if (width < 414) {
      return DeviceScreenType.standardPhone;
    } else if (width < 600) {
      return DeviceScreenType.largePhone;
    } else {
      return DeviceScreenType.tablet;
    }
  }

  static double getHorizontalPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.smallPhone:
        return 16.0;
      case DeviceScreenType.standardPhone:
        return 20.0;
      case DeviceScreenType.largePhone:
        return 24.0;
      case DeviceScreenType.tablet:
        return 32.0;
    }
  }

  static double responsiveFontSize(BuildContext context, double baseSize) {
    final scaleFactor = MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.3);
    final width = MediaQuery.of(context).size.width;
    double deviceScale = 1.0;
    if (width < 360) {
      deviceScale = 0.9;
    } else if (width > 600) {
      deviceScale = 1.1;
    }
    return baseSize * deviceScale * scaleFactor;
  }
}
