import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../helpers/pet_form_utils.dart';
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
      initialBirthdate:
          owner.birthdate != null ? parseDateString(owner.birthdate!) : null,
      initialLocation: owner.location,
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
      deleteAvailable: true,
      onDelete: () => _showDeleteOwnerConfirmation(context),
    );
  }

  void _updateOwner(BuildContext context, Map<String, dynamic> formData) {
    final updatedOwner = Owner(
      id: owner.id,
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

    Navigator.of(context).pop(updatedOwner);
    showInfoSnackBar(context, CompatibilityTexts.updateOwnerSuccess);
  }

  void _showDeleteOwnerConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete ${owner.name}?'),
          backgroundColor: AppTheme.primaryBackground,
          content: const Text(CompatibilityTexts.deleteConfirmation),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.primaryColor)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop('delete');
                showInfoSnackBar(
                    context, CompatibilityTexts.deleteOwnerSuccess);
              },
            ),
          ],
        );
      },
    );
  }
}
