import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomTimePicker extends StatelessWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const CustomTimePicker({
    super.key,
    this.initialTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _selectTime(context),
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

  Future<void> _selectTime(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme.copyWith(
      primary: AppTheme.primaryColor,
      onPrimary: Colors.white,
      surface: AppTheme.secondaryBackground,
      onSurface: AppTheme.primaryText,
    );

    final ThemeData timePickerTheme = ThemeData(
      colorScheme: colorScheme,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppTheme.secondaryBackground,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        dayPeriodBorderSide: const BorderSide(color: AppTheme.primaryColor),
        dayPeriodColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppTheme.primaryColor
                : AppTheme.secondaryBackground),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppTheme.primaryColor),
        hourMinuteColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppTheme.primaryColor
                : AppTheme.secondaryBackground),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppTheme.primaryColor),
      ),
      textTheme: theme.textTheme.copyWith(
        bodyMedium: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.primaryText),
        labelSmall: theme.textTheme.labelSmall?.copyWith(color: AppTheme.secondaryText),
      ),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: timePickerTheme,
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != initialTime) {
      onTimeSelected(picked);
    }
  }
}