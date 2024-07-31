import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../helpers/pet_form_utils.dart';
import '../helpers/show_snackbar.dart';
import '../helpers/constants.dart';
import '../models/pet_model.dart';
import '../widgets/pet_form.dart';

class CreatePetScreen extends StatelessWidget {
  const CreatePetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PetForm(
      onSubmit: (formData) => _createPet(context, formData),
      submitButtonName: 'Create Pet',
    );
  }

  void _createPet(BuildContext context, Map<String, dynamic> formData) {
    final newPet = Pet(
      id: const Uuid().v4(),
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

    Navigator.of(context).pop(newPet);
    showInfoSnackBar(context, PetCompatibilityTexts.createSuccess);
  }
}
