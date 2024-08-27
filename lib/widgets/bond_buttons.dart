import 'package:flutter/material.dart';
import '../config/theme.dart';

class BondButtons extends StatelessWidget {
  final Function(String) onNavigate;

  const BondButtons({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: 70,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 4),
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_sharp,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    onPressed: () => print('Last Result pressed ...'),
                    iconSize: 50,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                    ),
                    style: IconButton.styleFrom(
                      shape: CircleBorder(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height * 0.14,
          ),
          _buildIntroLine(context),
          _buildCompatibilityButton(
            context,
            'Parent\nPet',
            'assets/images/owner_pet.png',
            () => onNavigate('/owner/compatability'),
          ),
          _buildCompatibilityButton(
            context,
            'Pet\nPet',
            'assets/images/petpet.png',
            () => onNavigate('/pet/compatability'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroLine(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(-1, 0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(25, 0, 0, 0),
        child: Container(
          decoration: const BoxDecoration(),
          child: Text(
            'Create profiles and discover matches!',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  letterSpacing: 0,
                ),
          ),
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 190,
          decoration: BoxDecoration(
            color: AppTheme.alternateColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accent1,
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
                          color: AppTheme.primaryColor,
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
      ),
    );
  }
}
