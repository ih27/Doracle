import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_router.dart';
import '../widgets/nav_bar.dart';
import 'home_screen.dart';
import 'unified_fortune_screen.dart';
import '../widgets/bond_buttons.dart';
import 'assessment_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<CustomAppBarState> _appBarKey = GlobalKey<CustomAppBarState>();
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
        navigateToHome: _navigateToHome,
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

  void _navigateToHome() {
    setState(() {
      _selectedIndex = 0;
      _currentTitle = '';
      _updateCustomAppBar();
    });
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
      navigateToHome: _navigateToHome,
      onPurchaseComplete: _onPurchaseComplete,
      onBackPressed: () => _navigatorKey.currentState?.pop(),
    ));
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return UnifiedFortuneScreen(
          fromPurchase: _fromPurchase,
        );
      case 2:
        return BondButtons(onNavigate: _navigateTo);
      case 3:
        return const AssessmentScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: Navigator(
        key: _navigatorKey,
        observers: [_appRouter.observer],
        onGenerateRoute: (settings) {
          if (_selectedIndex == 0 && settings.name == '/') {
            return MaterialPageRoute(
              builder: (_) => _getScreenForIndex(_selectedIndex),
              settings: settings,
            );
          }
          return _appRouter.onGenerateRoute(settings) ?? 
               MaterialPageRoute(builder: (_) => const SizedBox.shrink());
        },
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _currentTitle = '';
            _updateCustomAppBar();
          });
          _navigatorKey.currentState?.popUntil((route) => route.isFirst);
        },
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