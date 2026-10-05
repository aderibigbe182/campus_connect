import 'package:flutter/material.dart';

class AppDurations {
  AppDurations._();

  // ==========================================
  // VERY FAST
  // ==========================================

  static const Duration instant =
      Duration(milliseconds: 50);

  static const Duration veryFast =
      Duration(milliseconds: 100);

  // ==========================================
  // FAST
  // ==========================================

  static const Duration fast =
      Duration(milliseconds: 200);

  // ==========================================
  // NORMAL
  // ==========================================

  static const Duration normal =
      Duration(milliseconds: 300);

  // ==========================================
  // MEDIUM
  // ==========================================

  static const Duration medium =
      Duration(milliseconds: 400);

  // ==========================================
  // SLOW
  // ==========================================

  static const Duration slow =
      Duration(milliseconds: 600);

  // ==========================================
  // VERY SLOW
  // ==========================================

  static const Duration verySlow =
      Duration(milliseconds: 800);

  // ==========================================
  // CURVES
  // ==========================================

  static const Curve standardCurve =
      Curves.easeInOut;

  static const Curve emphasizedCurve =
      Curves.easeInOutCubic;

  static const Curve decelerateCurve =
      Curves.easeOut;

  static const Curve accelerateCurve =
      Curves.easeIn;

  static const Curve bounceCurve =
      Curves.elasticOut;
}