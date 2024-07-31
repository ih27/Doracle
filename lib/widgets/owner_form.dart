import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../helpers/pet_form_utils.dart';
import '../widgets/custom_datepicker.dart';
import '../widgets/custom_underline_textfield.dart';
import '../widgets/map_overlay.dart';
import '../widgets/sendable_textfield.dart';
import '../config/theme.dart';
import '../helpers/constants.dart';

class OwnerForm extends StatefulWidget {
  final String? initialName;
  final String? initialGender;
  final DateTime? initialBirthdate;
  final String? initialLocation;
  final List<String> initialInterests;
  final int initialActivityLevel;
  final int initialPetExperience;
  final bool deleteAvailable;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onDelete;
  final String submitButtonName;

  const OwnerForm({
    super.key,
    this.initialName,
    this.initialGender,
    this.initialBirthdate,
    this.initialLocation,
    this.initialInterests = const [],
    this.initialActivityLevel = 2,
    this.initialPetExperience = 2,
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
  late TextEditingController _locationController;

  String? _gender;
  DateTime? _birthdate;
  String? _location;
  late List<String> _interests;
  late int _activityLevel;
  late int _petExperience;

  String? _nameError;
  String? _genderError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _birthdateController = TextEditingController(
      text: widget.initialBirthdate != null
          ? formatDate(widget.initialBirthdate!)
          : '',
    );
    _locationController = TextEditingController(text: widget.initialLocation);

    _gender = widget.initialGender;
    _birthdate = widget.initialBirthdate;
    _location = widget.initialLocation;
    _interests = List.from(widget.initialInterests);
    _activityLevel = widget.initialActivityLevel;
    _petExperience = widget.initialPetExperience;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showMapOverlay() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapOverlay(
          onLocationSelected: (LatLng location, String address) {
            setState(() {
              _location = address;
              _locationController.text = _location!;
            });
          },
        );
      },
    );
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
              labelText: 'Owner Name',
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
            _buildLocationSection(),
            const SizedBox(height: 8),
            const Divider(
              thickness: 2,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            _buildInterestsSection(),
            const SizedBox(height: 8),
            _buildSliderSection(
              title: 'Activity Level',
              value: _activityLevel,
              onChanged: (newValue) {
                setState(() => _activityLevel = newValue);
              },
            ),
            const SizedBox(height: 8),
            _buildSliderSection(
              title: 'Pet Experience',
              value: _petExperience,
              onChanged: (newValue) {
                setState(() => _petExperience = newValue);
              },
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
                _buildGenderChip('Male', FontAwesomeIcons.mars),
                _buildGenderChip('Female', FontAwesomeIcons.venus),
                _buildGenderChip('Other', FontAwesomeIcons.transgender),
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
              'Birthdate',
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
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
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
              'Location',
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
                    controller: _locationController,
                    readOnly: true,
                  ),
                ),
                ElevatedButton(
                  onPressed: _showMapOverlay,
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.titleSmall?.color,
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.3, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Select',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.info,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
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
              'Interests',
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
                _buildInterestChip('Dogs'),
                _buildInterestChip('Cats'),
                _buildInterestChip('Birds'),
                _buildInterestChip('Fish'),
                _buildInterestChip('Reptiles'),
                _buildInterestChip('Small Animals'),
                _buildInterestChip('Outdoors'),
                _buildInterestChip('Training'),
              ],
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
  }) {
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
          max: 3,
          divisions: 2,
          value: value.toDouble(),
          onChanged: (newValue) => onChanged(newValue.round()),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 0,
                    ),
              ),
              Text(
                'Medium',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      letterSpacing: 0,
                    ),
              ),
              Text(
                'High',
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

  Widget _buildGenderChip(String label, IconData icon) {
    final isSelected = _gender == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          _gender = selected ? label : null;
          if (_genderError != null) {
            _genderError = null;
          }
        });
      },
      avatar: Icon(icon,
          size: 18,
          color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText),
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

  Widget _buildInterestChip(String label) {
    final isSelected = _interests.contains(label);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _interests.add(label);
          } else {
            _interests.remove(label);
          }
        });
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
        'location': _location,
        'interests': _interests,
        'activityLevel': _activityLevel,
        'petExperience': _petExperience,
      });
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

    return isValid;
  }
}
