import 'package:flutter/material.dart';
import '../config/theme.dart';

class BondButtons extends StatelessWidget {
  final Function(String) onNavigate;

  const BondButtons({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCompatibilityButton(
            context,
            'You\n',
            'assets/images/owner_pet.png',
            () => onNavigate('/ownercompatability'),
          ),
          const SizedBox(height: 20),
          _buildCompatibilityButton(
            context,
            'Pet\nPet',
            'assets/images/petpet.png',
            () => onNavigate('/petcompatability'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityButton(
    BuildContext context,
    String title,
    String imagePath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 190,
        decoration: BoxDecoration(
          color: AppTheme.lemonChiffon,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.secondaryColor,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.secondaryColor,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(1, 1),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                child: Container(
                  width: 200,
                  height: 170,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      image: AssetImage(imagePath),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}