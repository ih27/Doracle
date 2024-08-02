import 'package:flutter/material.dart';
import '../config/dependency_injection.dart';
import '../helpers/list_space_divider.dart';
import '../entities/entity_manager.dart';
import '../widgets/entity_carousel.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';

class PetCompatabilityScreen extends StatefulWidget {
  const PetCompatabilityScreen({super.key});

  @override
  _PetCompatabilityScreenState createState() => _PetCompatabilityScreenState();
}

class _PetCompatabilityScreenState extends State<PetCompatabilityScreen> {
  final PetManager _petManager = getIt<PetManager>();
  Pet? selectedPet1;
  Pet? selectedPet2;

  bool get isCompatibilityCheckEnabled =>
      selectedPet1 != null &&
      selectedPet2 != null &&
      selectedPet1 != selectedPet2;

  @override
  void initState() {
    super.initState();
    _initializePets();
  }

  Future<void> _initializePets() async {
    await _petManager.loadEntities();
    if (_petManager.entities.isNotEmpty) {
      setState(() {
        selectedPet1 = selectedPet2 = _petManager.entities[0];
      });
    }
  }

  Future<void> _addNewPet() async {
    final result = await Navigator.pushNamed(context, '/pet/create');
    if (result != null && result is Pet) {
      await _petManager.addEntity(result);
    }
  }

  Future<void> _editPet(Pet pet) async {
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

  void _selectPet(int index, bool isFirstCarousel) {
    if (index < _petManager.entities.length) {
      setState(() {
        if (isFirstCarousel) {
          selectedPet1 = _petManager.entities[index];
        } else {
          selectedPet2 = _petManager.entities[index];
        }
      });
    } else {
      setState(() {
        if (isFirstCarousel) {
          selectedPet1 = null;
        } else {
          selectedPet2 = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _petManager,
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
                    onPageChanged: (index) => _selectPet(index, true),
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
                      onPressed: isCompatibilityCheckEnabled
                          ? () {
                              // Implement compatibility check logic here
                              debugPrint(
                                  'Checking compatibility between ${selectedPet1!.name} and ${selectedPet2!.name}');
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
                              color: isCompatibilityCheckEnabled
                                  ? AppTheme.info
                                  : AppTheme.secondaryText,
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
                  child: EntityCarousel<Pet>(
                    entities: _petManager.entities,
                    maxEntities: 10,
                    onAddEntity: _addNewPet,
                    onEditEntity: _editPet,
                    isPet: true,
                    onPageChanged: (index) => _selectPet(index, false),
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