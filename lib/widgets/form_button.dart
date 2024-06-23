// form_button.dart
import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final Widget? icon; // Add an optional icon parameter

  const FormButton({this.text = '', this.onPressed, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity, // Ensure the button takes the full width
      child: ElevatedButton.icon(
        onPressed: onPressed as void Function()?,
        icon: icon ?? const SizedBox.shrink(), // Display icon if provided
        label: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
