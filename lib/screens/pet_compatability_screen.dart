import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/list_space_divider.dart';
import '../widgets/pet_carousel.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';

class PetCompatabilityScreen extends StatefulWidget {
  const PetCompatabilityScreen({super.key});

  @override
  _PetCompatabilityScreenState createState() => _PetCompatabilityScreenState();
}

class _PetCompatabilityScreenState extends State<PetCompatabilityScreen> {
  List<Pet> pets = [];
  final String _petsStorageKey = 'pets_list';

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? petsJson = prefs.getString(_petsStorageKey);
    if (petsJson != null) {
      setState(() {
        pets = Pet.listFromJson(petsJson);
      });
    }
  }

  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_petsStorageKey, Pet.listToJson(pets));
  }

  void _addNewPet() async {
    final result = await Navigator.pushNamed(context, '/pet/create');
    if (result != null && result is Pet) {
      setState(() {
        pets.add(result);
      });
      await _savePets();
    }
  }

  void _editPet(Pet pet) async {
    final result = await Navigator.pushNamed(context, '/pet/edit',
        arguments: pet);
    if (result != null && result is Pet) {
      // TODO
    }
  }

  void _removePet(Pet pet) async {
    setState(() {
      pets.removeWhere((p) => p.id == pet.id);
    });
    await _savePets();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.25,
              decoration: const BoxDecoration(),
              child: PetCarousel(
                pets: pets,
                maxPets: 10,
                onAddPet: _addNewPet,
                onEditPet: _editPet,
              ),
            ),
          ),
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBackground,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Nothing for now
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.titleSmall?.color,
                    backgroundColor: AppTheme.accent1,
                    minimumSize:
                        Size(MediaQuery.of(context).size.width * 0.5, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Check Compatibility',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 0,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.25,
              decoration: const BoxDecoration(),
              child: PetCarousel(
                pets: pets,
                maxPets: 10,
                onAddPet: _addNewPet,
                onEditPet: _editPet,
              ),
            ),
          ),
        ].divide(height: 50),
      ),
    );
  }
}
