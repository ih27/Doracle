import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class CustomUnderlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomUnderlineTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.none,
      obscureText: false,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 0,
            ),
        hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 0,
            ),
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(
            color: AppTheme.alternateColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: const BorderSide(
            color: AppTheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: const BorderSide(
            color: AppTheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            letterSpacing: 0,
          ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}