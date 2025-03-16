import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../helpers/pet_owner_form_utils.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../models/owner_model.dart';
import '../widgets/owner_form.dart';
import '../config/dependency_injection.dart';
import '../services/auth_service.dart';

class CreateOwnerScreen extends StatelessWidget {
  final bool isInitialCreation;
  final AuthService _authService = getIt<AuthService>();

  CreateOwnerScreen({super.key, this.isInitialCreation = false});

  @override
  Widget build(BuildContext context) {
    // Get name directly from auth service if available (from Apple Sign In)
    final String? initialName = _authService.getNameFromCredential();

    return OwnerForm(
      initialName: initialName,
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
