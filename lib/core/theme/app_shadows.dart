import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // ==========================================
  // SMALL
  // ==========================================

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // ==========================================
  // MEDIUM
  // ==========================================

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ==========================================
  // LARGE
  // ==========================================

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ==========================================
  // FLOATING
  // ==========================================

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // ==========================================
  // DIALOG
  // ==========================================

  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.18),
      blurRadius: 30,
      offset: Offset(0, 16),
    ),
  ];
}