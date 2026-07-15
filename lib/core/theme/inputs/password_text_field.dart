import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<PasswordTextField> createState() =>
      _PasswordTextFieldState();
}

class _PasswordTextFieldState
    extends State<PasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      textInputAction: widget.textInputAction,

      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,

        prefixIcon: const Icon(Icons.lock_outline),

        suffixIcon: IconButton(
          onPressed: _toggleVisibility,
          icon: Icon(
            _obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }
}