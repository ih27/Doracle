import 'package:flutter/material.dart';
import '../config/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const SplashScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  VoidCallback get onSignIn => widget.onSignIn;
  VoidCallback get onSignUp => widget.onSignUp;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/doracle2_new.png'),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Image.asset(
                        'assets/images/doracle_logo_1@2x.webp',
                        width: 300,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(44, 8, 44, 0),
                          child: Text(
                            'Elevate your pet parenting!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 72),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 16),
                      child: ElevatedButton(
                        onPressed: onSignIn,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.bodyLarge?.color,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(230, 52),
                          elevation: 0,
                          side: const BorderSide(
                            color: AppTheme.alternateColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 16),
                      child: ElevatedButton(
                        onPressed: onSignUp,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.titleSmall?.color,
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: const Size(230, 52),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    letterSpacing: 0,
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
