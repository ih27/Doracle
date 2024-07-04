import 'package:flutter/material.dart';
import '../auth_wrapper.dart';
import 'home_screen.dart';
import 'fortune_tell_screen.dart';
import 'shop_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _navigateTo(String route) {
    _navigatorKey.currentState?.pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleSignOut(context),
          ),
          // Generated code for this IconButton Widget...
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 20, 0),
            child: IconButton(
              icon: const Icon(
                Icons.settings_suggest_rounded,
                size: 24,
              ),
              onPressed: () {
                // nothing for now
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
      ),
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder =
                  (BuildContext context) => HomeScreen(onNavigate: _navigateTo);
              break;
            case '/fortune':
              builder = (BuildContext context) =>
                  FortuneTellScreen(onNavigate: _navigateTo);
              break;
            case '/shop':
              builder =
                  (BuildContext context) => ShopScreen(onNavigate: _navigateTo);
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(
              builder: builder, settings: settings, fullscreenDialog: true);
        },
      ),
    );
  }
}
