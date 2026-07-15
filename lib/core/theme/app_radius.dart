import 'package:flutter/widgets.dart';

class AppRadius {
  AppRadius._();

  // ==================================
  // STANDARD RADII
  // ==================================

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double round = 30;
  static const double pill = 999;

  // ==================================
  // BORDER RADIUS
  // ==================================

  static const BorderRadius xsRadius =
      BorderRadius.all(
    Radius.circular(xs),
  );

  static const BorderRadius smRadius =
      BorderRadius.all(
    Radius.circular(sm),
  );

  static const BorderRadius mdRadius =
      BorderRadius.all(
    Radius.circular(md),
  );

  static const BorderRadius lgRadius =
      BorderRadius.all(
    Radius.circular(lg),
  );

  static const BorderRadius xlRadius =
      BorderRadius.all(
    Radius.circular(xl),
  );

  static const BorderRadius xxlRadius =
      BorderRadius.all(
    Radius.circular(xxl),
  );

  static const BorderRadius pillRadius =
      BorderRadius.all(
    Radius.circular(pill),
  );
}