import 'package:flutter/material.dart';

class NavigationHelper {
  NavigationHelper._();

  // -------------------------------
  // Push
  // -------------------------------

  static Future<T?> push<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // -------------------------------
  // Replace
  // -------------------------------

  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  // -------------------------------
  // Remove everything
  // -------------------------------

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
      (route) => false,
    );
  }

  // -------------------------------
  // Pop
  // -------------------------------

  static void pop<T>(
    BuildContext context, [
    T? result,
  ]) {
    Navigator.pop(context, result);
  }
}