import 'package:flutter/material.dart';
import '../helpers/pet_owner_form_utils.dart';
import '../helpers/show_snackbar.dart';
import 'custom_datepicker.dart';
import 'custom_timepicker.dart';
import 'custom_underline_textfield.dart';
import 'sendable_textfield.dart';
import '../config/theme.dart';
import '../helpers/constants.dart';

class OwnerForm extends StatefulWidget {
  final String? initialName;
  final String? initialGender;
  final DateTime? initialBirthdate;
  final TimeOfDay? initialBirthtime;
  //final String? initialLocation;
  final String? initialLivingSituation;
  final int initialActivityLevel;
  final int initialInteractionLevel;
  final String? initialWorkSchedule;
  final String? initialPetExperience;
  final int initialGroomingCommitment;
  final int initialNoiseTolerance;
  final String? initialPetReason;
  final bool deleteAvailable;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onDelete;
  final String submitButtonName;

  const OwnerForm({
    super.key,
    this.initialName,
    this.initialGender,
    this.initialBirthdate,
    this.initialBirthtime,
    //this.initialLocation,
    this.initialLivingSituation,
    this.initialActivityLevel = 2,
    this.initialInteractionLevel = 2,
    this.initialWorkSchedule,
    this.initialPetExperience,
    this.initialGroomingCommitment = 2,
    this.initialNoiseTolerance = 2,
    this.initialPetReason,
    this.deleteAvailable = false,
    required this.onSubmit,
    this.onDelete,
    required this.submitButtonName,
  });

  @override
  _OwnerFormState createState() => _OwnerFormState();
}

class _OwnerFormState extends State<OwnerForm> {
  late TextEditingController _nameController;
  late TextEditingController _birthdateController;
  late TextEditingController _birthtimeController;
  //late TextEditingController _locationController;

  String? _gender;
  DateTime? _birthdate;
  TimeOfDay? _birthtime;
  //String? _location;
  String? _livingSituation;
  late int _activityLevel;
  late int _interactionLevel;
  String? _workSchedule;
  String? _petExperience;
  late int _groomingCommitment;
  late int _noiseTolerance;
  String? _petReason;

  String? _nameError;
  String? _genderError;
  String? _birthdateError;
  String? _birthtimeError;
  String? _livingSituationError;
  String? _workScheduleError;
  String? _petExperienceError;
  String? _petReasonError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _birthdateController = TextEditingController(
      text: widget.initialBirthdate != null
          ? formatDate(widget.initialBirthdate!)
          : '',
    );
    _birthtimeController = TextEditingController(
      text: widget.initialBirthtime != null
          ? formatTime(widget.initialBirthtime!)
          : '',
    );
    //_locationController = TextEditingController(text: widget.initialLocation);

    _gender = widget.initialGender;
    _birthdate = widget.initialBirthdate;
    _birthtime = widget.initialBirthtime;
    //_location = widget.initialLocation;
    _livingSituation = widget.initialLivingSituation;
    _activityLevel = widget.initialActivityLevel;
    _interactionLevel = widget.initialInteractionLevel;
    _workSchedule = widget.initialWorkSchedule;
    _petExperience = widget.initialPetExperience;
    _groomingCommitment = widget.initialGroomingCommitment;
    _noiseTolerance = widget.initialNoiseTolerance;
    _petReason = widget.initialPetReason;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _birthtimeController.dispose();
    //_locationController.dispose();
    super.dispose();
  }

  // void _showMapOverlay() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return MapOverlay(
  //         onLocationSelected: (LatLng location, String address) {
  //           setState(() {
  //             _location = address;
  //             _locationController.text = _location!;
  //           });
  //         },
  //       );
  //     },
  //   );
  // }

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
              labelText: 'Your Name',
              onSubmitted: (_) {},
              onChanged: (value) {
                if (_nameError != null) {
                  setState(() {
                    _nameError = null;
                  });
                }
              },
              errorText: _nameError,
              maxLength: 40,
            ),
            const SizedBox(height: 8),
            _buildGenderSection(),
            const SizedBox(height: 8),
            _buildBirthdateSection(),
            const SizedBox(height: 8),
            _buildBirthtimeSection(),
            const SizedBox(height: 8),
            // _buildLocationSection(),
            // const SizedBox(height: 8),
            const Divider(
              thickness: 2,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            _buildSingleSelectSection(
              label: CompatibilityTexts.ownerLivingSituationLabel,
              options: CompatibilityTexts.ownerLivingSituationChoices,
              selectedValue: _livingSituation,
              onChanged: (String? newValue) {
                setState(() {
                  _livingSituation = newValue;
                  _livingSituationError = null;
                });
              },
              context: context,
              errorText: _livingSituationError,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              title: CompatibilityTexts.ownerActivityLevelLabel,
              value: _activityLevel,
              onChanged: (newValue) {
                setState(() => _activityLevel = newValue);
              },
              values: CompatibilityTexts.ownerActivityLevelChoices,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              title: CompatibilityTexts.ownerInteractionLevelLabel,
              value: _interactionLevel,
              onChanged: (newValue) {
                setState(() => _interactionLevel = newValue);
              },
              values: CompatibilityTexts.ownerInteractionLevelChoices,
            ),
            const SizedBox(height: 8),
            _buildSingleSelectSection(
              label: CompatibilityTexts.ownerWorkScheduleLabel,
              options: CompatibilityTexts.ownerWorkScheduleChoices,
              selectedValue: _workSchedule,
              onChanged: (String? newValue) {
                setState(() {
                  _workSchedule = newValue;
                  _workScheduleError = null;
                });
              },
              context: context,
              errorText: _workScheduleError,
            ),
            const SizedBox(height: 8),
            _buildSingleSelectSection(
              label: CompatibilityTexts.ownerPetExperienceLabel,
              options: CompatibilityTexts.ownerPetExperienceChoices,
              selectedValue: _petExperience,
              onChanged: (String? newValue) {
                setState(() {
                  _petExperience = newValue;
                  _petExperienceError = null;
                });
              },
              context: context,
              errorText: _petExperienceError,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              title: CompatibilityTexts.ownerGroomingCommitmentLabel,
              value: _groomingCommitment,
              onChanged: (newValue) {
                setState(() => _groomingCommitment = newValue);
              },
              values: CompatibilityTexts.ownerGroomingCommitmentChoices,
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              title: CompatibilityTexts.ownerNoiseToleranceLabel,
              value: _noiseTolerance,
              onChanged: (newValue) {
                setState(() => _noiseTolerance = newValue);
              },
              values: CompatibilityTexts.ownerNoiseToleranceChoices,
            ),
            const SizedBox(height: 8),
            _buildSingleSelectSection(
              label: CompatibilityTexts.ownerPetReasonLabel,
              options: CompatibilityTexts.ownerPetReasonChoices,
              selectedValue: _petReason,
              onChanged: (String? newValue) {
                setState(() {
                  _petReason = newValue;
                  _petReasonError = null;
                });
              },
              context: context,
              errorText: _petReasonError,
            ),
            const SizedBox(height: 8),
            _buildFormButtons(widget.deleteAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _genderError != null ? AppTheme.error : AppTheme.alternateColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Gender',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildGenderSelection('Male', 'assets/images/owner_he.png'),
                _buildGenderSelection('Female', 'assets/images/owner_she.png'),
                _buildGenderSelection('Other', 'assets/images/owner_other.png'),
              ],
            ),
          ),
          if (_genderError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _genderError!,
                style: const TextStyle(color: AppTheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBirthdateSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.alternateColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Date of Birth',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: CustomUnderlineTextField(
                    controller: _birthdateController,
                    readOnly: true,
                  ),
                ),
                CustomDatePicker(
                  initialDate: _birthdate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onDateSelected: (DateTime date) {
                    setState(() {
                      _birthdate = date;
                      _birthdateController.text = formatDate(date);
                      _birthdateError = null;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_birthdateError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Text(
                _birthdateError!,
                style: const TextStyle(color: AppTheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBirthtimeSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.alternateColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Time of Birth',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: CustomUnderlineTextField(
                    controller: _birthtimeController,
                    readOnly: true,
                  ),
                ),
                CustomTimePicker(
                  initialTime: _birthtime,
                  onTimeSelected: (TimeOfDay time) {
                    setState(() {
                      _birthtime = time;
                      _birthtimeController.text = formatTime(time);
                      _birthtimeError = null;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_birthtimeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Text(
                _birthtimeError!,
                style: const TextStyle(color: AppTheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildLocationSection() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: AppTheme.secondaryBackground,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: AppTheme.alternateColor,
  //         width: 1,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(8),
  //           child: Text(
  //             'Location',
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                   color: AppTheme.primaryColor,
  //                   fontSize: 18,
  //                   letterSpacing: 0,
  //                 ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(8),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: CustomUnderlineTextField(
  //                   controller: _locationController,
  //                   readOnly: true,
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: _showMapOverlay,
  //                 style: ElevatedButton.styleFrom(
  //                   foregroundColor:
  //                       Theme.of(context).textTheme.titleSmall?.color,
  //                   backgroundColor: AppTheme.primaryColor,
  //                   minimumSize:
  //                       Size(MediaQuery.of(context).size.width * 0.3, 40),
  //                   padding: const EdgeInsets.symmetric(horizontal: 24),
  //                   elevation: 3,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Select',
  //                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
  //                         color: AppTheme.info,
  //                         letterSpacing: 0,
  //                       ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSingleSelectSection({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
    required BuildContext context,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.alternateColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (String optionName in options)
                  _buildSingleSelectChip(
                    optionName,
                    selectedValue,
                    onChanged,
                  )
              ],
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Text(
                errorText,
                style: const TextStyle(color: AppTheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    required List<String> values,
  }) {
    final sliderMax = values.length.toDouble();
    final divisions = values.length - 1;
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
          ),
        ),
        Slider(
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.alternateColor,
          min: 1,
          max: sliderMax,
          divisions: divisions,
          value: value.toDouble(),
          onChanged: (newValue) => onChanged(newValue.round()),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (String valueName in values)
                Text(
                  valueName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        letterSpacing: 0,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection(String label, String assetName) {
    final isSelected = _gender == label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _gender = isSelected ? null : label;
            if (_genderError != null) {
              _genderError = null;
            }
          });
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackground,
            border: Border.all(
              color: AppTheme.primaryColor,
              width: isSelected ? 5 : 1,
            ),
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(assetName),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleSelectChip(
    String optionName,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    final isSelected = selectedValue == optionName;
    return ChoiceChip(
      label: Text(optionName),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (bool selected) {
        onChanged(selected ? optionName : null);
      },
      backgroundColor: AppTheme.alternateColor,
      selectedColor: AppTheme.secondaryColor,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
            letterSpacing: 0,
          ),
      elevation: isSelected ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildFormButtons(bool deleteAvailable) {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: _submitForm,
            child: Text(widget.submitButtonName),
          ),
        ),
        if (deleteAvailable && widget.onDelete != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onDelete,
            child: const Text(
              'Delete Owner',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ]
      ],
    );
  }

  void _submitForm() {
    if (_validateForm()) {
      widget.onSubmit({
        'name': _nameController.text,
        'gender': _gender,
        'birthdate': _birthdate,
        'birthtime': _birthtime,
        //'location': _location,
        'livingSituation': _livingSituation,
        'activityLevel': _activityLevel,
        'interactionLevel': _interactionLevel,
        'workSchedule': _workSchedule,
        'petExperience': _petExperience,
        'groomingCommitment': _groomingCommitment,
        'noiseTolerance': _noiseTolerance,
        'petReason': _petReason,
      });
    } else {
      showErrorSnackBar(context, CompatibilityTexts.requiredFieldsError);
    }
  }

  bool _validateForm() {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = CompatibilityTexts.ownerNameError;
      });
      isValid = false;
    }

    if (_gender == null) {
      setState(() {
        _genderError = CompatibilityTexts.ownerGenderError;
      });
      isValid = false;
    }

    // New checks
    if (_birthdate == null) {
      setState(() {
        _birthdateError = CompatibilityTexts.ownerBirthdateError;
      });
      isValid = false;
    }

    if (_birthtime == null) {
      setState(() {
        _birthtimeError = CompatibilityTexts.ownerBirthtimeError;
      });
      isValid = false;
    }

    if (_livingSituation == null) {
      setState(() {
        _livingSituationError = CompatibilityTexts.ownerLivingSituationError;
      });
      isValid = false;
    }

    if (_workSchedule == null) {
      setState(() {
        _workScheduleError = CompatibilityTexts.ownerWorkScheduleError;
      });
      isValid = false;
    }

    if (_petExperience == null) {
      setState(() {
        _petExperienceError = CompatibilityTexts.ownerPetExperienceError;
      });
      isValid = false;
    }

    if (_petReason == null) {
      setState(() {
        _petReasonError = CompatibilityTexts.ownerPetReasonError;
      });
      isValid = false;
    }

    return isValid;
  }
}

// Widget _buildMultiSelectChip(String label) {
//     final isSelected = _interests.contains(label);
//     return FilterChip(
//       label: Text(label),
//       selected: isSelected,
//       showCheckmark: false,
//       onSelected: (bool selected) {
//         setState(() {
//           if (selected) {
//             _interests.add(label);
//           } else {
//             _interests.remove(label);
//           }
//         });
//       },
//       backgroundColor: AppTheme.alternateColor,
//       selectedColor: AppTheme.secondaryColor,
//       labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
//             letterSpacing: 0,
//           ),
//       elevation: isSelected ? 4 : 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//     );
//   }
