import 'package:flutter/material.dart';
import '../screens/owner_compatability_screen.dart';
import '../screens/pet_compatability_screen.dart';
import '../widgets/slide_right_route.dart';
import '../widgets/bond_buttons.dart';
import 'unified_fortune_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _fromPurchase = false;
  bool _canPop = false;
  String _currentTitle = '';
  final Map<String, String> _routeTitles = {
    '/': '',
    '/fortune': '',
    '/bond': 'Compatibility Check',
    '/petcompatability': '',
    '/ownercompatability': '',
  };

  void _navigateTo(String route, {String? title}) {
    setState(() {
      _currentTitle = title ?? _routeTitles[route] ?? '';
    });
    // _navigatorKey.currentState?.pushReplacementNamed(route);
    // During development we need this
    _navigatorKey.currentState?.pushNamed(route);
  }

  void _navigateToHome() {
    setState(() {
      _currentTitle = '';
    });
    //_navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _navigatorKey.currentState?.pushReplacementNamed('/fortune');
  }

  void _onPurchaseComplete() {
    setState(() {
      _fromPurchase = true;
    });
    _navigateTo('/fortune');
  }

  void _updateCanPop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _canPop = _navigatorKey.currentState?.canPop() ?? false;
      });
    });
  }

  void _updateTitle(Route<dynamic> route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentTitle = _routeTitles[route.settings.name] ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        automaticallyImplyLeading: false,
        leading: _canPop
            ? IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).primaryColor),
                onPressed: () => _navigatorKey.currentState?.pop(),
              )
            : null,
        title: Text(
          _currentTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          // During development we need this
          IconButton(
            icon: const Icon(
              Icons.home,
              size: 24,
            ),
            onPressed: _navigateToHome,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 20, 0),
            child: IconButton(
              icon: const Icon(
                Icons.settings_suggest_rounded,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  SlideRightRoute(
                    page: SettingsScreen(
                      onPurchaseComplete: _onPurchaseComplete,
                    ),
                  ),
                );
              },
              iconSize: 50,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 50,
              ),
              style: IconButton.styleFrom(
                shape: CircleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          )
        ],
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 0,
        forceMaterialTransparency: true,
      ),
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
            case '/fortune':
              builder = (BuildContext context) => UnifiedFortuneScreen(
                    onNavigate: _navigateTo,
                    fromPurchase: _fromPurchase,
                  );
              break;
            case '/bond':
              builder = (BuildContext context) =>
                  BondButtons(onNavigate: _navigateTo);
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
              builder: builder, settings: settings, fullscreenDialog: true);
        },
        observers: [
          _MainScreenNavigatorObserver(
              updateCanPop: _updateCanPop, updateTitle: _updateTitle),
        ],
      ),
    );
  }
}

class _MainScreenNavigatorObserver extends NavigatorObserver {
  final VoidCallback updateCanPop;
  final Function(Route<dynamic>) updateTitle;

  _MainScreenNavigatorObserver({
    required this.updateCanPop,
    required this.updateTitle,
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    updateCanPop();
    updateTitle(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    updateCanPop();
    if (previousRoute != null) {
      updateTitle(previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    updateCanPop();
    if (previousRoute != null) {
      updateTitle(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    updateCanPop();
    if (newRoute != null) {
      updateTitle(newRoute);
    }
  }
}
