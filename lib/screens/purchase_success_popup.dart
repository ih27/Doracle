import 'package:flutter/material.dart';

class PurchaseConfirmationDialog extends StatelessWidget {
  const PurchaseConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Processing your purchase...', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}