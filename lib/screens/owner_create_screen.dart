import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/pet_owner_form_utils.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../models/owner_model.dart';
import '../widgets/owner_form.dart';
import '../config/dependency_injection.dart';
import '../services/auth_service.dart';

class CreateOwnerScreen extends StatefulWidget {
  final bool isInitialCreation;
  final Function(Owner)? onOwnerCreated;

  const CreateOwnerScreen({
    super.key,
    this.isInitialCreation = false,
    this.onOwnerCreated,
  });

  @override
  _CreateOwnerScreenState createState() => _CreateOwnerScreenState();
}

class _CreateOwnerScreenState extends State<CreateOwnerScreen> {
  final AuthService _authService = getIt<AuthService>();
  String? _initialName;
  bool _isAppleSignIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // Get user data from Firebase Auth
    User? user = _authService.currentUser;
    debugPrint('CreateOwnerScreen - Current user: ${user?.uid}');
    debugPrint(
        'CreateOwnerScreen - Current user display name from Firebase: ${user?.displayName}');

    // Log provider data
    if (user?.providerData != null) {
      debugPrint(
          'CreateOwnerScreen - Provider data count: ${user!.providerData.length}');
      for (var provider in user.providerData) {
        debugPrint('CreateOwnerScreen - Provider ID: ${provider.providerId}');
        debugPrint(
            'CreateOwnerScreen - Provider display name: ${provider.displayName}');
        debugPrint('CreateOwnerScreen - Provider email: ${provider.email}');
      }
    }

    // Check if user signed in with Apple
    bool isAppleUser =
        user?.providerData.any((info) => info.providerId == 'apple.com') ??
            false;

    debugPrint('User signed in with Apple: $isAppleUser');

    // Set Apple sign in flag
    _isAppleSignIn = isAppleUser;

    if (_isAppleSignIn) {
      debugPrint('CreateOwnerScreen - Attempting to get Apple user name');
      // Try to get name from various sources, prioritizing secure storage
      String? name = await _authService.getAppleUserName();

      debugPrint('Name from AuthService: $name');

      // Check cached name in AuthService
      String? cachedName = _authService.getNameFromCredential();
      debugPrint(
          'CreateOwnerScreen - Cached name from credentials: $cachedName');

      // Only update state if component is still mounted and name is not null
      if (mounted && name != null) {
        debugPrint('CreateOwnerScreen - Setting initial name to: $name');
        setState(() {
          _initialName = name;
        });
      } else {
        debugPrint(
            'CreateOwnerScreen - Name not set: mounted=$mounted, name=$name');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CreateOwnerScreen build - initialName: $_initialName');
    return OwnerForm(
      initialName: _initialName,
      onSubmit: (formData) => _createOwner(context, formData),
      submitButtonName: CompatibilityTexts.createOwner,
    );
  }

  void _createOwner(BuildContext context, Map<String, dynamic> formData) {
    final newOwner = Owner(
      id: const Uuid().v4(),
      name: formData['name'],
      gender: formData['gender'],
      birthdate: formatDate(formData['birthdate']),
      birthtime: formatTime(formData['birthtime']),
      //location: formData['location'],
      livingSituation: formData['livingSituation'],
      activityLevel: formData['activityLevel'],
      interactionLevel: formData['interactionLevel'],
      workSchedule: formData['workSchedule'],
      petExperience: formData['petExperience'],
      groomingCommitment: formData['groomingCommitment'],
      noiseTolerance: formData['noiseTolerance'],
      petReason: formData['petReason'],
    );

    if (widget.isInitialCreation && widget.onOwnerCreated != null) {
      // Use the callback for initial creation
      widget.onOwnerCreated!(newOwner);
    } else {
      // Standard behavior for regular use
      Navigator.of(context).pop(newOwner);
    }

    showInfoSnackBar(context, CompatibilityTexts.createOwnerSuccess);
  }
}
