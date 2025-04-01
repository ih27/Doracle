import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../helpers/pet_owner_form_utils.dart';
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
      submitButtonName: CompatibilityTexts.createPet,
    );
  }

  void _createPet(BuildContext context, Map<String, dynamic> formData) {
    final newPet = Pet(
      id: const Uuid().v4(),
      name: formData['name'],
      species: formData['species'],
      breed: formData['breed'],
      birthdate: formatDate(formData['birthdate']),
      birthtime: formatTime(formData['birthtime']),
      //location: formData['location'],
      temperament: formData['temperament'],
      exerciseRequirement: formData['exerciseRequirement'],
      socializationNeed: formData['socializationNeed'],
    );

    Navigator.of(context).pop(newPet);
    showInfoSnackBar(context, CompatibilityTexts.createPetSuccess);
  }
}
