import 'package:flutter/material.dart';
import '../screens/unified_fortune_screen.dart';
import '../screens/owner_compatability_screen.dart';
import '../screens/pet_compatability_screen.dart';
import '../screens/pet_create_screen.dart';
import 'bond_buttons.dart';
import 'fade_page_route.dart';

class AppRouter extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(String, {String? title}) onNavigate;
  final bool fromPurchase;
  final NavigatorObserver observer;

  AppRouter({
    super.key,
    required this.navigatorKey,
    required this.onNavigate,
    required this.observer,
    this.fromPurchase = false,
  });

  final Map<String, String> _routeTitles = {
    '/': '',
    '/fortune': '',
    '/bond': 'Compatibility Check',
    '/pet/compatability': 'Compatibility Check',
    '/pet/create': 'Create Pet',
    '/owner/compatability': 'Owner Compatibility',
  };

  String getRouteTitle(String route) {
    return _routeTitles[route] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: '/',
      observers: [observer],
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
          case '/fortune':
            builder = (BuildContext context) => UnifiedFortuneScreen(
                  onNavigate: onNavigate,
                  fromPurchase: fromPurchase,
                );
            break;
          case '/bond':
            builder =
                (BuildContext context) => BondButtons(onNavigate: onNavigate);
            break;
          case '/pet/compatability':
            builder = (BuildContext context) => const PetCompatabilityScreen();
            break;
          case '/pet/create':
            builder = (BuildContext context) => const CreatePetScreen();
            break;
          case '/owner/compatability':
            builder =
                (BuildContext context) => const OwnerCompatabilityScreen();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return FadePageRoute(
          page: builder(context),
          settings: settings,
        );
      },
    );
  }
}
