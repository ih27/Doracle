import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_router.dart';
import '../widgets/nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<CustomAppBarState> _appBarKey =
      GlobalKey<CustomAppBarState>();
  int _selectedIndex = 0;
  bool _fromPurchase = false;
  bool _canPop = false;
  String _currentTitle = '';
  late final AppRouter _appRouter;
  late final CustomAppBar _appBar;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      navigatorKey: _navigatorKey,
      onNavigate: _navigateTo,
      observer: _MainScreenNavigatorObserver(
        updateCanPop: _updateCanPop,
        updateTitle: _updateTitle,
      ),
      fromPurchase: _fromPurchase,
    );
    _appBar = CustomAppBar(
      key: _appBarKey,
      data: CustomAppBarData(
        canPop: _canPop,
        currentTitle: _currentTitle,
        onPurchaseComplete: _onPurchaseComplete,
        onBackPressed: () => _navigatorKey.currentState?.pop(),
      ),
    );
  }

  void _navigateTo(String route, {String? title}) {
    setState(() {
      _currentTitle = title ?? _appRouter.getRouteTitle(route);
      _updateCustomAppBar();
    });
    _navigatorKey.currentState?.pushNamed(route);
  }

  void _onPurchaseComplete() {
    setState(() {
      _fromPurchase = true;
      _selectedIndex = 1; // Navigate to Oracle screen
    });
  }

  void _updateCanPop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _canPop = _navigatorKey.currentState?.canPop() ?? false;
        _updateCustomAppBar();
      });
    });
  }

  void _updateTitle(Route<dynamic> route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentTitle = _appRouter.getRouteTitle(route.settings.name ?? '');
        _updateCustomAppBar();
      });
    });
  }

  void _updateCustomAppBar() {
    _appBarKey.currentState?.update(CustomAppBarData(
      canPop: _canPop,
      currentTitle: _currentTitle,
      onPurchaseComplete: _onPurchaseComplete,
      onBackPressed: () => _navigatorKey.currentState?.pop(),
    ));
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/fortune';
      case 2:
        return '/bond';
      case 3:
        return '/assessment';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: Navigator(
        key: _navigatorKey,
        observers: [_appRouter.observer],
        onGenerateRoute: _appRouter.onGenerateRoute,
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _currentTitle = _appRouter.getRouteTitle(_getRouteForIndex(index));
            _updateCustomAppBar();
          });
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            _getRouteForIndex(index),
            (route) => false,
          );
        },
      ),
    );
  }
}

class _MainScreenNavigatorObserver extends NavigatorObserver {
  final VoidCallback updateCanPop;
  final Function(Route<dynamic>) updateTitle;

  _MainScreenNavigatorObserver(
      {required this.updateCanPop, required this.updateTitle});

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
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    updateCanPop();
    if (newRoute != null) {
      updateTitle(newRoute);
    }
  }
}
