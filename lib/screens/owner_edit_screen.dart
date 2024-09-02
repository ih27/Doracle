import 'package:flutter/material.dart';
import '../helpers/pet_owner_form_utils.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../models/owner_model.dart';
import '../widgets/owner_form.dart';

class UpdateOwnerScreen extends StatelessWidget {
  final Owner owner;

  const UpdateOwnerScreen({super.key, required this.owner});

  @override
  Widget build(BuildContext context) {
    return OwnerForm(
      initialName: owner.name,
      initialGender: owner.gender,
      initialBirthdate: parseDateString(owner.birthdate),
      initialBirthtime: parseTimeString(owner.birthtime),
      //initialLocation: owner.location,
      initialLivingSituation: owner.livingSituation,
      initialActivityLevel: owner.activityLevel,
      initialInteractionLevel: owner.interactionLevel,
      initialWorkSchedule: owner.workSchedule,
      initialPetExperience: owner.petExperience,
      initialGroomingCommitment: owner.groomingCommitment,
      initialNoiseTolerance: owner.noiseTolerance,
      initialPetReason: owner.petReason,
      onSubmit: (formData) => _updateOwner(context, formData),
      submitButtonName: CompatibilityTexts.updateOwner,
    );
  }

  void _updateOwner(BuildContext context, Map<String, dynamic> formData) {
    final updatedOwner = Owner(
      id: owner.id,
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

    Navigator.of(context).pop(updatedOwner);
    showInfoSnackBar(context, CompatibilityTexts.updateOwnerSuccess);
  }
}
