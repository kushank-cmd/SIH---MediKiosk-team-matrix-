import 'package:flutter/material.dart';

/// Responsive layout helper utilities for MediKiosk.
/// Designed for tablet kiosks (~10-12 inches) and mobile phones.
class Responsive {
  Responsive._();

  /// Tablet breakpoint threshold based on shortest side in logical pixels
  static const double tabletShortestSide = 600.0;
  static const double desktopThreshold = 1024.0;

  /// Returns true if the device is a tablet kiosk (shortestSide >= 600)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= tabletShortestSide;
  }

  /// Returns true if the device is a phone (shortestSide < 600)
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < tabletShortestSide;
  }

  /// Returns orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns appropriate horizontal screen padding
  static EdgeInsets screenPadding(BuildContext context) {
    final tablet = isTablet(context);
    return EdgeInsets.symmetric(
      horizontal: tablet ? 32.0 : 16.0,
      vertical: tablet ? 24.0 : 16.0,
    );
  }

  /// Returns 2 columns for tablet kiosk and 1 column for phone
  static int gridColumns(BuildContext context, {int phone = 1, int tablet = 2, int wideTablet = 3}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopThreshold) return wideTablet;
    if (isTablet(context)) return tablet;
    return phone;
  }

  /// Responsive content max width wrapper to keep layouts centered on ultra-wide screens
  static const double maxContentWidth = 1100.0;
}
