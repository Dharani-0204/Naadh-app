import 'package:flutter/material.dart';

abstract final class AppShapes {
  static const double cardRadius = 20;
  static const double buttonRadius = 16;
  static const double chipRadius = 999;

  static RoundedRectangleBorder card = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardRadius),
  );
}
