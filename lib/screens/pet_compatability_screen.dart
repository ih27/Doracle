import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/list_space_divider.dart';
import '../viewmodels/entity_manager.dart';
import '../widgets/entity_carousel.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';

class PetCompatabilityScreen extends StatelessWidget {
  const PetCompatabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetManager>(
      builder: (context, petManager, child) {
        void addNewPet() async {
          final result = await Navigator.pushNamed(context, '/pet/create');
          if (result != null && result is Pet) {
            await petManager.addEntity(result);
          }
        }

        void editPet(Pet pet) async {
          final result = await Navigator.pushNamed(context, '/pet/edit', arguments: pet);
          if (result != null) {
            if (result is Pet) {
              await petManager.updateEntity(pet, result);
            } else if (result == 'delete') {
              await petManager.removeEntity(pet);
            }
          }
        }

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
                    entities: petManager.entities,
                    maxEntities: 10,
                    onAddEntity: addNewPet,
                    onEditEntity: editPet,
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
                        // Nothing for now
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).textTheme.titleSmall?.color,
                        backgroundColor: AppTheme.accent1,
                        minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 50),
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
                  child: EntityCarousel<Pet>(
                    entities: petManager.entities,
                    maxEntities: 10,
                    onAddEntity: addNewPet,
                    onEditEntity: editPet,
                    isPet: true,
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