import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';

class PetCarousel extends StatefulWidget {
  final int maxPets;

  const PetCarousel({super.key, required this.maxPets});

  @override
  _PetCarouselState createState() => _PetCarouselState();
}

class _PetCarouselState extends State<PetCarousel> {
  List<Pet> pets = [];
  late CarouselController carouselController;
  final String _petsStorageKey = 'pets_list';

  @override
  void initState() {
    super.initState();
    carouselController = CarouselController();
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

  List<Widget> get carouselItems {
    List<Widget> items = pets.map((pet) => _buildPetItem(pet)).toList();
    if (pets.length < widget.maxPets) {
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
              width: 170, // Reduced from 180
              height: 170, // Reduced from 180
              decoration: BoxDecoration(
                color: AppTheme.lemonChiffon,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  //image: NetworkImage(pet.imageUrl),
                  image: AssetImage(pet.imageUrl),
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.secondaryColor,
                  width: 2,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removePet(pet),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5), // Reduced from 10
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              pet.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryColor,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _addNewPet,
          child: Container(
            width: 170, // Reduced from 180
            height: 170, // Reduced from 180
            decoration: BoxDecoration(
              color: AppTheme.lemonChiffon,
              image: const DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/images/plus.png'),
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.secondaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5), // Reduced from 10
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Add',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryColor,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  void _addNewPet() async {
    if (pets.length < widget.maxPets) {
      // Here you would typically show a dialog or navigate to a new screen to get pet details
      // For this example, we'll just add a dummy pet
      final newPet = Pet(
        id: const Uuid().v4(),
        name: 'New Pet ${pets.length + 1}',
        //imageUrl: 'https://example.com/pet_image.jpg',
        imageUrl: 'assets/images/dog.png',
      );
      setState(() {
        pets.add(newPet);
      });
      await _savePets();
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
    return CarouselSlider.builder(
      itemCount: carouselItems.length,
      itemBuilder: (context, index, _) => carouselItems[index],
      carouselController: carouselController,
      options: CarouselOptions(
        viewportFraction: 0.5,
        disableCenter: true,
        enlargeCenterPage: true,
        enlargeFactor: 0.35,
        enableInfiniteScroll: false,
      ),
    );
  }
}
