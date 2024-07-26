import 'package:flutter/material.dart';
import '../screens/unified_fortune_screen.dart';
import '../screens/owner_compatability_screen.dart';
import '../screens/pet_compatability_screen.dart';
import '../widgets/bond_buttons.dart';

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
    '/petcompatability': 'Pet Compatibility',
    '/ownercompatability': 'Owner Compatibility',
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
            builder = (BuildContext context) =>
                BondButtons(onNavigate: onNavigate);
            break;
          case '/petcompatability':
            builder =
                (BuildContext context) => const PetCompatabilityScreen();
            break;
          case '/ownercompatability':
            builder =
                (BuildContext context) => const OwnerCompatabilityScreen();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(
            builder: builder, 
            settings: settings,
            fullscreenDialog: true);
      },
    );
  }
}