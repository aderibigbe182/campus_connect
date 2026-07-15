import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;

  final PreferredSizeWidget? appBar;

  final Widget? floatingActionButton;

  final Widget? bottomNavigationBar;

  final Widget? bottomSheet;

  final Color? backgroundColor;

  final bool resizeToAvoidBottomInset;

  final bool useSafeArea;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (useSafeArea) {
      content = SafeArea(
        child: body,
      );
    }

    return Scaffold(
      backgroundColor:
          backgroundColor ??
          AppColors.background,

      appBar: appBar,

      body: content,

      floatingActionButton:
          floatingActionButton,

      bottomNavigationBar:
          bottomNavigationBar,

      bottomSheet: bottomSheet,

      resizeToAvoidBottomInset:
          resizeToAvoidBottomInset,
    );
  }
}