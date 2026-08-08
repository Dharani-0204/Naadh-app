import 'package:flutter/widgets.dart';

abstract final class Responsive {
  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isLargePhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 420;

  static double adaptivePadding(BuildContext context) {
    if (isSmallPhone(context)) return 12;
    if (isLargePhone(context)) return 20;
    return 16;
  }
}
