import 'package:flutter/material.dart';

class BondButtons extends StatelessWidget {
  final Function(String) onNavigate;

  const BondButtons({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => onNavigate('/petcompatability'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
            ),
            child: const Text('Pet / Pet'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onNavigate('/ownercompatability'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
            ),
            child: const Text('Pet / You'),
          ),
        ],
      ),
    );
  }
}