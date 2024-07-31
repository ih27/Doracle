import 'package:flutter/material.dart';
import '../helpers/pet_form_utils.dart';
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
      initialLocation: pet.location,
      initialTemperament: pet.temperament,
      initialExerciseRequirement: pet.exerciseRequirement,
      initialSocializationNeed: pet.socializationNeed,
      onSubmit: (formData) => _updatePet(context, formData),
      submitButtonName: 'Update Pet',
      deleteAvailable: true,
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
      location: formData['location'],
      temperament: formData['temperament'],
      exerciseRequirement: formData['exerciseRequirement'],
      socializationNeed: formData['socializationNeed'],
    );

    Navigator.of(context).pop(updatedPet);
    showInfoSnackBar(context, PetCompatibilityTexts.updateSuccess);
  }
}
