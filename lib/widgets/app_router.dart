import 'package:flutter/material.dart';
import '../screens/compatibility_result_card_screen.dart';
import '../screens/compatibility_result_screen.dart';
import '../screens/assessment_screen.dart';
import '../screens/home_screen.dart';
import '../screens/improvement_plan_screen.dart';
import '../screens/last_results_screen.dart';
import '../screens/owner_create_screen.dart';
import '../screens/owner_edit_screen.dart';
import '../screens/pet_edit_screen.dart';
import '../screens/unified_fortune_screen.dart';
import '../screens/owner_compatability_screen.dart';
import '../screens/pet_compatability_screen.dart';
import '../screens/pet_create_screen.dart';
import '../helpers/constants.dart';
import '../widgets/bond_buttons.dart';
import 'fade_page_route.dart';

class AppRouter {
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(String, {String? title}) onNavigate;
  final bool fromPurchase;
  final NavigatorObserver observer;

  AppRouter({
    required this.navigatorKey,
    required this.onNavigate,
    required this.observer,
    this.fromPurchase = false,
  });

  final Map<String, String> _routeTitles = {
    '/': CompatibilityTexts.noTitle,
    '/oracle': CompatibilityTexts.noTitle,
    '/bond': CompatibilityTexts.compatibilityTitle,
    '/assessment': CompatibilityTexts.noTitle,
    '/pet/compatability': CompatibilityTexts.checkTitle,
    '/pet/create': CompatibilityTexts.createPet,
    '/pet/edit': CompatibilityTexts.updatePet,
    '/owner/compatability': CompatibilityTexts.checkTitle,
    '/owner/create': CompatibilityTexts.createOwner,
    '/owner/edit': CompatibilityTexts.updateOwner,
    '/result': CompatibilityTexts.resultTitle,
    '/result/card': CompatibilityTexts.noTitle,
    '/last_results': CompatibilityTexts.noTitle,
    '/improvement_plan': CompatibilityTexts.noTitle,
  };

  String getRouteTitle(String route) {
    return _routeTitles[route] ?? '';
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    switch (settings.name) {
      case '/':
        builder = (BuildContext context) => const HomeScreen();
        break;
      case '/oracle':
        builder = (BuildContext context) => UnifiedFortuneScreen(
              fromPurchase: fromPurchase,
            );
        break;
      case '/bond':
        builder = (BuildContext context) => BondButtons(onNavigate: onNavigate);
        break;
      case '/assessment':
        builder = (BuildContext context) => const AssessmentScreen();
        break;
      case '/pet/compatability':
        builder = (BuildContext context) => const PetCompatabilityScreen();
        break;
      case '/pet/create':
        builder = (BuildContext context) => const CreatePetScreen();
        break;
      case '/pet/edit':
        final args = settings.arguments as Map<String, dynamic>;
        builder = (BuildContext context) => UpdatePetScreen(pet: args['pet']);
        break;
      case '/owner/compatability':
        builder = (BuildContext context) => const OwnerCompatabilityScreen();
        break;
      case '/owner/create':
        builder = (BuildContext context) => const CreateOwnerScreen();
        break;
      case '/owner/edit':
        final args = settings.arguments as Map<String, dynamic>;
        builder =
            (BuildContext context) => UpdateOwnerScreen(owner: args['owner']);
        break;
      case '/result':
        final args = settings.arguments as Map<String, dynamic>;
        builder = (BuildContext context) => CompatibilityResultScreen(
              entity1: args['entity1'],
              entity2: args['entity2'],
              scores: args['scores'],
            );
        break;
      case '/result/card':
        final args = settings.arguments as Map<String, dynamic>;
        builder = (BuildContext context) => CompatibilityResultCardScreen(
            cardId: args['cardId'], planId: args['planId']);
        break;
      case '/last_results':
        builder = (BuildContext context) => const LastResultsScreen();
        break;
      case '/improvement_plan':
        final args = settings.arguments as Map<String, dynamic>;
        builder = (BuildContext context) =>
            ImprovementPlanScreen(planId: args['planId']);
        break;
      default:
        return null;
    }
    return FadePageRoute(
      page: builder(navigatorKey.currentContext!),
      settings: settings,
    );
  }
}
