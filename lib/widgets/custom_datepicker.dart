import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePicker({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _selectDate(context),
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).textTheme.titleSmall?.color,
        backgroundColor: AppTheme.primaryColor,
        minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Select',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.info,
              letterSpacing: 0,
            ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme.copyWith(
      primary: AppTheme.primaryColor,
      onPrimary: Colors.white,
      surface: AppTheme.secondaryBackground,
      onSurface: AppTheme.primaryText,
    );

    final ThemeData datePickerTheme = ThemeData(
      colorScheme: colorScheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
        ),
      ),
      textTheme: theme.textTheme.copyWith(
        bodyMedium:
            theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryText),
        labelSmall:
            theme.textTheme.labelSmall?.copyWith(color: AppTheme.secondaryText),
      ),
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: datePickerTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }
}
