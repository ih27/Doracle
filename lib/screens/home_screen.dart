import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to Doracle\n\nTo be designed...',
          style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
