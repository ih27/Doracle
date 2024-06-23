import 'package:flutter/material.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Function? onPressed;
  final Widget? icon; // Add this line to accept an icon

  const FormButton({
    this.text = '',
    this.onPressed,
    this.icon, // Add this line to accept an icon
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton.icon(
      icon: icon ?? const SizedBox.shrink(), // Use the provided icon or an empty widget
      label: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      onPressed: onPressed as void Function()?,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenHeight * .02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
