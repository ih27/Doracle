import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../helpers/pet_form_utils.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../models/owner_model.dart';
import '../widgets/owner_form.dart';

class CreateOwnerScreen extends StatelessWidget {
  const CreateOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OwnerForm(
      onSubmit: (formData) => _createOwner(context, formData),
      submitButtonName: CompatibilityTexts.createOwner,
    );
  }

  void _createOwner(BuildContext context, Map<String, dynamic> formData) {
    final newOwner = Owner(
      id: const Uuid().v4(),
      name: formData['name'],
      gender: formData['gender'],
      birthdate: formData['birthdate'] != null
          ? formatDate(formData['birthdate'])
          : null,
      location: formData['location'],
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
