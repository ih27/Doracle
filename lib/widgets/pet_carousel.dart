import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';

class PetCarousel extends StatelessWidget {
  final List<Pet> pets;
  final int maxPets;
  final VoidCallback onAddPet;
  final Function(Pet) onEditPet;

  const PetCarousel({
    super.key,
    required this.pets,
    required this.maxPets,
    required this.onAddPet,
    required this.onEditPet,
  });

  List<Widget> get carouselItems {
    List<Widget> items = pets.map((pet) => _buildPetItem(pet)).toList();
    if (pets.length < maxPets) {
      items.add(_buildAddItem());
    }
    return items;
  }

  Widget _buildPetItem(Pet pet) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AppTheme.alternateColor,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(_getSpeciesImage(pet.species)),
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 4, 0),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                onPressed: () => onEditPet(pet),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.alternateColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(35, 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              pet.name,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getSpeciesImage(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return 'assets/images/dog.png';
      case 'cat':
        return 'assets/images/cat.png';
      case 'bird':
        return 'assets/images/bird.png';
      default:
        return 'assets/images/other.png';
    }
  }

  Widget _buildAddItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onAddPet,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              color: AppTheme.alternateColor,
              image: const DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/plus.png'),
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Add',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: carouselItems.length,
      itemBuilder: (context, index, _) => carouselItems[index],
      options: CarouselOptions(
        viewportFraction: 0.5,
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
        enableInfiniteScroll: false,
        pageSnapping: true,
        scrollPhysics: const PageScrollPhysics(),
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
