import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).textTheme.titleSmall?.color,
        backgroundColor: AppTheme.primaryColor,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 40),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.info),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.info,
                  letterSpacing: 0,
                ),
          ),
        ],
      ),
    );
  }
}