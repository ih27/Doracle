import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../config/theme.dart';
import '../models/pet_model.dart';
import '../models/owner_model.dart';

class EntityCarousel<T> extends StatelessWidget {
  final List<T> entities;
  final int maxEntities;
  final VoidCallback onAddEntity;
  final Function(T) onEditEntity;
  final Function(int)? onPageChanged;
  final bool isPet;
  final CarouselSliderController carouselController;
  final int initialPage;

  const EntityCarousel({
    super.key,
    required this.entities,
    required this.maxEntities,
    required this.onAddEntity,
    required this.onEditEntity,
    this.onPageChanged,
    required this.isPet,
    required this.carouselController,
    this.initialPage = 0,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCarousel(context);
  }

  Widget _buildCarousel(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth * 0.4;
        final itemHeight = itemWidth; // Square aspect ratio

        List<Widget> carouselItems = entities
            .map((entity) =>
                _buildEntityItem(context, entity, itemWidth, itemHeight))
            .toList();

        if (entities.length < maxEntities) {
          carouselItems.add(_buildAddItem(context, itemWidth, itemHeight));
        }

        return CarouselSlider(
          items: carouselItems,
          carouselController: carouselController,
          options: CarouselOptions(
            viewportFraction: 0.5,
            enlargeCenterPage: true,
            enlargeFactor: 0.1,
            enableInfiniteScroll: false,
            pageSnapping: true,
            scrollPhysics: const PageScrollPhysics(),
            scrollDirection: Axis.horizontal,
            initialPage: initialPage,
            onPageChanged: (index, reason) {
              if (onPageChanged != null) {
                onPageChanged!(index);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEntityItem(
      BuildContext context, T entity, double width, double height) {
    String name = isPet ? (entity as Pet).name : (entity as Owner).name;
    String imageAsset = _getEntityImage(entity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: AppTheme.alternateColor,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(imageAsset),
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
                onPressed: () => onEditEntity(entity),
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
              name,
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

  Widget _buildAddItem(BuildContext context, double width, double height) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onAddEntity,
          child: Container(
            width: width,
            height: height,
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
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isPet ? 'Add Pet' : 'Add',
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

  String _getEntityImage(T entity) {
    if (isPet) {
      switch ((entity as Pet).species.toLowerCase()) {
        case 'dog':
          return 'assets/images/dog.png';
        case 'cat':
          return 'assets/images/cat.png';
        case 'bird':
          return 'assets/images/bird.png';
        default:
          return 'assets/images/fish.png';
      }
    } else {
      switch ((entity as Owner).gender.toLowerCase()) {
        case 'male':
          return 'assets/images/owner_he.png';
        case 'female':
          return 'assets/images/owner_she.png';
        default:
          return 'assets/images/owner_other.png';
      }
    }
  }
}
