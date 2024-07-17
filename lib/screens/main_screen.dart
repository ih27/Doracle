import 'package:flutter/material.dart';
import '../widgets/slide_right_route.dart';
import 'unified_fortune_screen.dart';
import 'settings_screen.dart';

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

  void _onPurchaseComplete() {
    _navigateTo('/fortune');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        automaticallyImplyLeading: false,
        actions: [
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
                  );
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