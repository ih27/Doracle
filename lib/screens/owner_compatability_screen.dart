import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/list_space_divider.dart';
import '../widgets/entity_carousel.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';
import '../models/owner_model.dart';

class OwnerCompatabilityScreen extends StatefulWidget {
  const OwnerCompatabilityScreen({super.key});

  @override
  _OwnerCompatabilityScreenState createState() =>
      _OwnerCompatabilityScreenState();
}

class _OwnerCompatabilityScreenState extends State<OwnerCompatabilityScreen> {
  List<Pet> pets = [];
  List<Owner> owners = [];
  final String _petsStorageKey = 'pets_list';
  final String _ownersStorageKey = 'owners_list';

  @override
  void initState() {
    super.initState();
    _loadPets();
    _loadOwners();
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

  Future<void> _loadOwners() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ownersJson = prefs.getString(_ownersStorageKey);
    if (ownersJson != null) {
      setState(() {
        owners = Owner.listFromJson(ownersJson);
      });
    }
  }

  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_petsStorageKey, Pet.listToJson(pets));
  }

  Future<void> _saveOwners() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownersStorageKey, Owner.listToJson(owners));
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
    final result =
        await Navigator.pushNamed(context, '/pet/edit', arguments: pet);
    if (result != null) {
      if (result is Pet) {
        _updatePet(pet, result);
      } else if (result == 'delete') {
        _removePet(pet);
      }
    }
  }

  void _updatePet(Pet pet, Pet updatedPet) async {
    setState(() {
      int index = pets.indexWhere((p) => p.id == pet.id);
      if (index != -1) {
        pets[index] = updatedPet;
      }
    });
    await _savePets();
  }

  void _removePet(Pet pet) async {
    setState(() {
      pets.removeWhere((p) => p.id == pet.id);
    });
    await _savePets();
  }

  void _addNewOwner() async {
    final result = await Navigator.pushNamed(context, '/owner/create');
    if (result != null && result is Owner) {
      setState(() {
        owners.add(result);
      });
      await _saveOwners();
    }
  }

  void _editOwner(Owner owner) async {
    final result =
        await Navigator.pushNamed(context, '/owner/edit', arguments: owner);
    if (result != null) {
      if (result is Owner) {
        _updateOwner(owner, result);
      } else if (result == 'delete') {
        _removeOwner(owner);
      }
    }
  }

  void _updateOwner(Owner owner, Owner updatedOwner) async {
    setState(() {
      int index = owners.indexWhere((o) => o.id == owner.id);
      if (index != -1) {
        owners[index] = updatedOwner;
      }
    });
    await _saveOwners();
  }

  void _removeOwner(Owner owner) async {
    setState(() {
      owners.removeWhere((o) => o.id == owner.id);
    });
    await _saveOwners();
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
              child: EntityCarousel(
                entities: pets,
                maxEntities: 10,
                onAddEntity: _addNewPet,
                onEditEntity: (entity) => _editPet(entity as Pet),
                isPet: true,
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
                    // Implement compatibility check logic
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
              child: EntityCarousel(
                entities: owners,
                maxEntities: 10,
                onAddEntity: _addNewOwner,
                onEditEntity: (entity) => _editOwner(entity as Owner),
                isPet: false,
              ),
            ),
          ),
        ].divide(height: 50),
      ),
    );
  }
}
