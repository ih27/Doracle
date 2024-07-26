import '../helpers/list_space_divider.dart';
import '../widgets/pet_carousel.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class PetCompatabilityScreen extends StatelessWidget {
  const PetCompatabilityScreen({super.key});

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
              child: const PetCarousel(maxPets: 10),
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
                    print('Button pressed ...');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).textTheme.titleSmall?.color,
                    backgroundColor: AppTheme.primaryColor,
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
              child: const PetCarousel(maxPets: 10),
            ),
          ),
        ].divide(height: 50),
      ),
    );
  }
}
