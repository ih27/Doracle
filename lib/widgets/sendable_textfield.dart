import 'package:doracle/config/theme.dart';
import 'package:flutter/material.dart';

class SendableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool useHintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String) onSubmitted;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final String? errorText;
  final FocusNode? focusNode;

  const SendableTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onSubmitted,
    this.useHintText = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.errorText,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.go,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: AppTheme.humanTextStyle,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: useHintText ? labelText : null,
        errorText: errorText,
        suffixIcon: suffixIcon,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
