import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_text_styles.dart';

class OtpTextField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final ValueChanged<String>? onCompleted;

  const OtpTextField({
    super.key,
    required this.controllers,
    this.onCompleted,
  }) : assert(
          controllers.length == 6,
          'OtpTextField requires exactly 6 controllers.',
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) {
          return SizedBox(
            width: 50,
            height: 60,
            child: TextField(
              controller: controllers[index],

              textAlign: TextAlign.center,

              keyboardType: TextInputType.number,

              textInputAction: TextInputAction.next,

              maxLength: 1,

              style: AppTextStyles.titleMedium,

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],

              decoration: InputDecoration(
                counterText: "",

                filled: true,

                fillColor: AppColors.surface,

                border: OutlineInputBorder(
                  borderRadius: AppRadius.lgRadius,
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lgRadius,
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lgRadius,
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),

              onChanged: (value) {

                if (value.isNotEmpty && index < 5) {
                  FocusScope.of(context).nextFocus();
                }

                if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }

                final code = controllers
                    .map((e) => e.text)
                    .join();

                if (code.length == 6 &&
                    !code.contains('')) {
                  onCompleted?.call(code);
                }
              },
            ),
          );
        },
      ),
    );
  }
}