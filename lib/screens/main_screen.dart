import 'package:flutter/material.dart';
import 'settings_screen.dart';
import '../widgets/slide_right_route.dart';
import '../widgets/app_router.dart';

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
  late final AppRouter _appRouter;
  late final _MainScreenNavigatorObserver _navigatorObserver;

  @override
  void initState() {
    super.initState();
    _navigatorObserver = _MainScreenNavigatorObserver(
      updateCanPop: _updateCanPop,
      updateTitle: _updateTitle,
    );
    _appRouter = AppRouter(
      navigatorKey: _navigatorKey,
      onNavigate: _navigateTo,
      observer: _navigatorObserver,
      fromPurchase: _fromPurchase,
    );
  }

  void _navigateTo(String route, {String? title}) {
    setState(() {
      _currentTitle = title ?? _appRouter.getRouteTitle(route);
    });
    _navigatorKey.currentState?.pushNamed(route);
  }

  void _navigateToHome() {
    setState(() {
      _currentTitle = '';
    });
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
        _currentTitle = _appRouter.getRouteTitle(route.settings.name ?? '');
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
      body: _appRouter,
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
