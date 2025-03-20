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

  const CreateOwnerScreen({super.key, this.isInitialCreation = false});

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
    // Set Apple sign in flag
    _isAppleSignIn =
        user?.providerData.any((info) => info.providerId == 'apple.com') ??
            false;

    if (_isAppleSignIn) {
      // Try to get name from various sources, prioritizing secure storage
      String? name = await _authService.getAppleUserName();
      // Only update state if component is still mounted and name is not null
      if (mounted && name != null) {
        setState(() {
          _initialName = name;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    Navigator.of(context).pop(newOwner);
    showInfoSnackBar(context, CompatibilityTexts.createOwnerSuccess);
  }
}
