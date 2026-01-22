import 'package:flutter/material.dart';

abstract class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;

  static const Duration compassUpdate = Duration(milliseconds: 16);
  static const Curve compassCurve = Curves.easeOutCubic;
}
