import 'package:flutter/material.dart';
import '../config/theme.dart';

class HomeContent extends StatelessWidget {
  final String welcomeMessage;
  final VoidCallback onOraclePressed;
  final VoidCallback onBondPressed;

  const HomeContent({
    super.key,
    required this.welcomeMessage,
    required this.onOraclePressed,
    required this.onBondPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  welcomeMessage,
                  textAlign: TextAlign.center,
                  style: AppTheme.dogTextStyle,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
          child: Column(
            children: [
              _buildOracleButton(context),
              const SizedBox(height: 25),
              _buildBondButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOracleButton(BuildContext context) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.secondaryColor,
            AppTheme.yaleBlue,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOraclePressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              'Oracle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBondButton(BuildContext context) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.naplesYellow,
            AppTheme.sandyBrown,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBondPressed,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(
                Icons.favorite, // Replace with FFIcons.ktwoHearth if available
                color: AppTheme.secondaryBackground,
                size: 35,
              ),
              Text(
                'Bond',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondaryBackground,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
              ),
              const Icon(
                Icons.favorite, // Replace with FFIcons.ktwoHearth if available
                color: AppTheme.secondaryBackground,
                size: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
