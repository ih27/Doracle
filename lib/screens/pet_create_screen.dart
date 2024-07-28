import 'package:doracle/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_datepicker.dart';
import '../widgets/sendable_textfield.dart';
import '../widgets/single_select_dropdown.dart';
import '../helpers/show_snackbar.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key});

  @override
  _CreatePetScreenState createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _species;
  DateTime? _birthdate;
  String? _location;
  String? _temperament;
  String? _exerciseRequirement;
  String? _socializationNeed;

  String? _nameError;
  String? _speciesError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SendableTextField(
              controller: _nameController,
              labelText: 'Pet Name',
              onSubmitted: (_) {},
              onChanged: (value) {
                if (_nameError != null) {
                  setState(() {
                    _nameError = null;
                  });
                }
              },
              errorText: _nameError,
            ),
            const SizedBox(height: 16),
            SingleSelect(
              label: 'Species',
              value: _species,
              options: const ['Dog', 'Cat', 'Bird', 'Other'],
              onChanged: (value) {
                setState(() {
                  _species = value;
                  if (_speciesError != null) {
                    _speciesError = null;
                  }
                });
              },
              errorText: _speciesError,
            ),
            const SizedBox(height: 16),
            Center(
              child: CustomDatePicker(
                initialDate: _birthdate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                onDateSelected: (date) => setState(() => _birthdate = date),
                labelText: 'Birthdate',
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CustomButton(
                text: _location == null
                    ? 'Select Location'
                    : 'Location: $_location',
                onPressed: () {
                  // Implement location selection
                  setState(() => _location = 'Istanbul, Türkiye');
                },
                icon: Icons.place,
              ),
            ),
            const SizedBox(height: 16),
            SingleSelect(
              label: 'Temperament',
              value: _temperament,
              options: const ['Friendly', 'Shy', 'Energetic', 'Calm'],
              onChanged: (value) => setState(() => _temperament = value),
            ),
            const SizedBox(height: 16),
            SingleSelect(
              label: 'Exercise Requirements',
              value: _exerciseRequirement,
              options: const ['Low', 'Medium', 'High'],
              onChanged: (value) =>
                  setState(() => _exerciseRequirement = value),
            ),
            const SizedBox(height: 16),
            SingleSelect(
              label: 'Socialization Needs',
              value: _socializationNeed,
              options: const ['Low', 'Medium', 'High'],
              onChanged: (value) => setState(() => _socializationNeed = value),
            ),
            const SizedBox(height: 32),
            Center(
              child: CustomButton(
                text: 'Create Pet',
                onPressed: _createPet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createPet() async {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = PetCompatibilityTexts.nameError;
      });
      isValid = false;
    }

    if (_species == null) {
      setState(() {
        _speciesError = PetCompatibilityTexts.speciesError;
      });
      isValid = false;
    }

    if (!isValid) {
      showErrorSnackBar(context, PetCompatibilityTexts.requiredFieldsError);
      return;
    }

    final newPet = Pet(
      id: const Uuid().v4(),
      name: _nameController.text,
      species: _species!,
      birthdate: _birthdate != null
          ? "${_birthdate!.year}-${_birthdate!.month.toString().padLeft(2, '0')}-${_birthdate!.day.toString().padLeft(2, '0')}"
          : null,
      location: _location,
      temperament: _temperament,
      exerciseRequirement: _exerciseRequirement,
      socializationNeed: _socializationNeed,
    );

    // Return the new pet to the previous screen
    Navigator.of(context).pop(newPet);

    // Show success message
    if (!mounted) return;
    showInfoSnackBar(context, PetCompatibilityTexts.createSuccess);
  }
}
