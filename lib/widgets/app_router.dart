import 'package:flutter/material.dart';
import '../screens/compatibility_result_screen.dart';
import '../screens/owner_create_screen.dart';
import '../screens/owner_edit_screen.dart';
import '../screens/pet_edit_screen.dart';
import '../screens/unified_fortune_screen.dart';
import '../screens/owner_compatability_screen.dart';
import '../screens/pet_compatability_screen.dart';
import '../screens/pet_create_screen.dart';
import '../helpers/constants.dart';
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
    '/bond': CompatibilityTexts.genericTitle,
    '/pet/compatability': CompatibilityTexts.genericTitle,
    '/pet/create': CompatibilityTexts.createPet,
    '/pet/edit': CompatibilityTexts.updatePet,
    '/owner/compatability': CompatibilityTexts.genericTitle,
    '/owner/create': CompatibilityTexts.createOwner,
    '/owner/edit': CompatibilityTexts.updateOwner,
    '/result': CompatibilityTexts.resultTitle,
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
          case '/pet/edit':
            final args = settings.arguments as Map<String, dynamic>;
            builder =
                (BuildContext context) => UpdatePetScreen(pet: args['pet']);
            break;
          case '/owner/compatability':
            builder =
                (BuildContext context) => const OwnerCompatabilityScreen();
            break;
          case '/owner/create':
            builder = (BuildContext context) => const CreateOwnerScreen();
            break;
          case '/owner/edit':
            final args = settings.arguments as Map<String, dynamic>;
            builder = (BuildContext context) =>
                UpdateOwnerScreen(owner: args['owner']);
            break;
          case '/result':
            final args = settings.arguments as Map<String, dynamic>;
            builder = (BuildContext context) => CompatibilityResultScreen(
                  entity1: args['entity1'],
                  entity2: args['entity2'],
                );
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
