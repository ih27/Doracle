import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../helpers/list_space_divider.dart';
import '../entities/entity_manager.dart';
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
  final PetManager _petManager = getIt<PetManager>();
  final OwnerManager _ownerManager = getIt<OwnerManager>();
  Pet? selectedPet;
  Owner? selectedOwner;

  bool get isCompatibilityCheckEnabled =>
      selectedPet != null && selectedOwner != null;

  @override
  void initState() {
    super.initState();
    _initializePets();
    _initializeOwners();
  }

  Future<void> _initializePets() async {
    await _petManager.loadEntities();
    if (_petManager.entities.isNotEmpty) {
      setState(() {
        selectedPet = _petManager.entities[0];
      });
    }
  }

  Future<void> _initializeOwners() async {
    await _ownerManager.loadEntities();
    if (_ownerManager.entities.isNotEmpty) {
      setState(() {
        selectedOwner = _ownerManager.entities[0];
      });
    }
  }

  void _addNewPet() async {
    final result = await Navigator.pushNamed(context, '/pet/create');
    if (result != null && result is Pet) {
      await _petManager.addEntity(result);
    }
  }

  void _editPet(Pet pet) async {
    final result =
        await Navigator.pushNamed(context, '/pet/edit', arguments: pet);
    if (result != null) {
      if (result is Pet) {
        await _petManager.updateEntity(pet, result);
      } else if (result == 'delete') {
        await _petManager.removeEntity(pet);
      }
    }
  }

  void _selectPet(int index) {
    setState(() {
      if (index < _petManager.entities.length) {
        selectedPet = _petManager.entities[index];
      } else {
        selectedPet = null;
      }
    });
  }

  void _addNewOwner() async {
    final result = await Navigator.pushNamed(context, '/owner/create');
    if (result != null && result is Owner) {
      await _ownerManager.addEntity(result);
    }
  }

  void _editOwner(Owner owner) async {
    final result =
        await Navigator.pushNamed(context, '/owner/edit', arguments: owner);
    if (result != null) {
      if (result is Owner) {
        await _ownerManager.updateEntity(owner, result);
      } else if (result == 'delete') {
        await _ownerManager.removeEntity(owner);
      }
    }
  }

  void _selectOwner(int index) {
    setState(() {
      if (index < _ownerManager.entities.length) {
        selectedOwner = _ownerManager.entities[index];
      } else {
        selectedOwner = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_petManager, _ownerManager]),
      builder: (context, child) {
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
                  child: EntityCarousel<Pet>(
                    entities: _petManager.entities,
                    maxEntities: 10,
                    onAddEntity: _addNewPet,
                    onEditEntity: _editPet,
                    isPet: true,
                    onPageChanged: _selectPet,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
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
                      onPressed: isCompatibilityCheckEnabled
                          ? () {
                              // Implement compatibility check logic here
                              debugPrint(
                                  'Checking compatibility between ${selectedPet!.name} and ${selectedOwner!.name}');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).textTheme.titleSmall?.color,
                        backgroundColor: isCompatibilityCheckEnabled
                            ? AppTheme.primaryColor
                            : AppTheme.accent1,
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.5, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: isCompatibilityCheckEnabled ? 3 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isCompatibilityCheckEnabled
                                ? Colors.transparent
                                : AppTheme.primaryColor,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
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
                  child: EntityCarousel<Owner>(
                    entities: _ownerManager.entities,
                    maxEntities: 5,
                    onAddEntity: _addNewOwner,
                    onEditEntity: _editOwner,
                    isPet: false,
                    onPageChanged: _selectOwner,
                  ),
                ),
              ),
            ].divide(height: 50),
          ),
        );
      },
    );
  }
}
