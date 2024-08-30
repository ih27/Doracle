import 'package:flutter/material.dart';
import '../screens/owner_create_screen.dart';
import '../helpers/constants.dart';

class InitialOwnerCreationScreen extends StatelessWidget {
  const InitialOwnerCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          CompatibilityTexts.createOwner,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        automaticallyImplyLeading: false, // Disable back button
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      body: const CreateOwnerScreen(isInitialCreation: true),
    );
  }
}
