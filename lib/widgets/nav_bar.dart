import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 360,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(70),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavItem(context, 0, 'assets/images/home.png'),
              _buildNavItem(context, 1, 'assets/images/oracle.png'),
              _buildNavItem(context, 2, 'assets/images/bond.png'),
              _buildNavItem(context, 3, 'assets/images/assesment.png'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String imagePath) {
    bool isSelected = selectedIndex == index;
    double size = isSelected ? 80 : 40;
    double borderWidth = isSelected ? 8 : 1;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor,
              width: borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.asset(
              imagePath,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}