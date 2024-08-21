import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../helpers/pet_owner_form_utils.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../models/pet_model.dart';
import '../widgets/pet_form.dart';

class UpdatePetScreen extends StatelessWidget {
  final Pet pet;

  const UpdatePetScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return PetForm(
      initialName: pet.name,
      initialSpecies: pet.species,
      initialBirthdate:
          pet.birthdate != null ? parseDateString(pet.birthdate!) : null,
      initialBirthtime:
          pet.birthtime != null ? parseTimeString(pet.birthtime!) : null,
      initialLocation: pet.location,
      initialTemperament: pet.temperament,
      initialExerciseRequirement: pet.exerciseRequirement,
      initialSocializationNeed: pet.socializationNeed,
      onSubmit: (formData) => _updatePet(context, formData),
      submitButtonName: CompatibilityTexts.updatePet,
      deleteAvailable: true,
      onDelete: () => _showDeletePetConfirmation(context),
    );
  }

  void _updatePet(BuildContext context, Map<String, dynamic> formData) {
    final updatedPet = Pet(
      id: pet.id,
      name: formData['name'],
      species: formData['species'],
      birthdate: formData['birthdate'] != null
          ? formatDate(formData['birthdate'])
          : null,
      birthtime: formData['birthtime'] != null
          ? formatTime(formData['birthtime'])
          : null,
      location: formData['location'],
      temperament: formData['temperament'],
      exerciseRequirement: formData['exerciseRequirement'],
      socializationNeed: formData['socializationNeed'],
    );

    Navigator.of(context).pop(updatedPet);
    showInfoSnackBar(context, CompatibilityTexts.updatePetSuccess);
  }

  void _showDeletePetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete ${pet.name}?'),
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
                showInfoSnackBar(context, CompatibilityTexts.deletePetSuccess);
              },
            ),
          ],
        );
      },
    );
  }
}
