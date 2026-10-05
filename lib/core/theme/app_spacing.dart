import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  // ==========================
  // SPACE VALUES
  // ==========================

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 48;

  // ==========================
  // PAGE PADDING
  // ==========================

  static const EdgeInsets page =
      EdgeInsets.symmetric(horizontal: 20);

  static const EdgeInsets pageVertical =
      EdgeInsets.symmetric(vertical: 20);

  static const EdgeInsets pageAll =
      EdgeInsets.all(20);

  // ==========================
  // CHAT
  // ==========================

  static const EdgeInsets chatTile =
      EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      );

  static const EdgeInsets messageBubble =
      EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      );

  // ==========================
  // INPUTS
  // ==========================

  static const EdgeInsets input =
      EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      );

  // ==========================
  // BUTTONS
  // ==========================

  static const EdgeInsets button =
      EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      );

  // ==========================
  // CARDS
  // ==========================

  static const EdgeInsets card =
      EdgeInsets.all(16);

  // ==========================
  // LISTS
  // ==========================

  static const EdgeInsets list =
      EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      );
}