import 'package:flutter/material.dart';

class LastResultsScreen extends StatelessWidget {
  const LastResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Latest Compatibility Results',
          style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}