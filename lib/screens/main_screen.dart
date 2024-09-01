import 'package:flutter/material.dart';
import '../global_key.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_router.dart';
import '../widgets/nav_bar.dart';
import '../screens/home_screen.dart';
import '../screens/unified_fortune_screen.dart';
import '../widgets/bond_buttons.dart';
import '../screens/assessment_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _fromPurchase = false;
  final Map<int, String> _lastTitles = {};
  final Map<int, bool> _canPopStates = {};
  late final AppRouter _appRouter;
  late final PageController _pageController;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _updateAppBarState(Route<dynamic> route) {
    if (route.settings.name != null) {
      setState(() {
        _lastTitles[_selectedIndex] =
            _appRouter.getRouteTitle(route.settings.name!);
        _canPopStates[_selectedIndex] =
            _navigatorKeys[_selectedIndex].currentState?.canPop() ?? false;
      });
    }
  }

  void _handleNavBarLongPress(int index) {
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    setState(() {
      _lastTitles[index] = _appRouter.getRouteTitle(_getRouteForIndex(index));
      _canPopStates[index] = false;
    });
    if (_selectedIndex != index) {
      _onItemTapped(index);
    }
  }

  void _initializeTabState(int index) {
    if (!_lastTitles.containsKey(index)) {
      _lastTitles[index] = _appRouter.getRouteTitle(_getRouteForIndex(index));
    }
    if (!_canPopStates.containsKey(index)) {
      _canPopStates[index] = false;
    }
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _initializeTabState(i);
    }
    _pageController = PageController();
    _appRouter = AppRouter(
      navigatorKey: navigatorKey,
      onNavigate: _navigateTo,
      observer: _MainScreenNavigatorObserver(
        updateAppBarState: _updateAppBarState,
      ),
      fromPurchase: _fromPurchase,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateTo(String route, {String? title}) {
    setState(() {
      _lastTitles[_selectedIndex] = title ?? _appRouter.getRouteTitle(route);
    });
    _navigatorKeys[_selectedIndex].currentState?.pushNamed(route);
  }

  void _onPurchaseComplete() {
    setState(() {
      _fromPurchase = true;
      _selectedIndex = 1;
    });
    _pageController.jumpToPage(1);
    // Force a rebuild of UnifiedFortuneScreen
    _navigatorKeys[_selectedIndex].currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => UnifiedFortuneScreen(fromPurchase: _fromPurchase),
            settings: RouteSettings(name: _getRouteForIndex(_selectedIndex)),
          ),
        );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    String currentTitle = _lastTitles[_selectedIndex] ??
        _appRouter.getRouteTitle(_getRouteForIndex(_selectedIndex));
    bool canPop = _canPopStates[_selectedIndex] ?? false;

    return Scaffold(
      appBar: CustomAppBar(
        data: CustomAppBarData(
          canPop: canPop,
          currentTitle: currentTitle,
          onPurchaseComplete: _onPurchaseComplete,
          onBackPressed: () =>
              _navigatorKeys[_selectedIndex].currentState?.pop(),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildNavigator(0, const HomeScreen()),
          _buildNavigator(1, UnifiedFortuneScreen(fromPurchase: _fromPurchase)),
          _buildNavigator(2, BondButtons(onNavigate: _navigateTo)),
          _buildNavigator(3, const AssessmentScreen()),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _lastTitles[_selectedIndex] = _getTitleForIndex(index);
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 1),
        child: SafeArea(
          child: NavBar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
            onItemLongPressed: _handleNavBarLongPress,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        if (settings.name == '/' || settings.name == null) {
          return MaterialPageRoute(
            builder: (_) => child,
            settings: RouteSettings(name: _getRouteForIndex(index)),
          );
        }
        return _appRouter.onGenerateRoute(settings);
      },
      observers: [_appRouter.observer],
    );
  }

  String _getTitleForIndex(int index) {
    return _appRouter.getRouteTitle(_getRouteForIndex(index));
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/';
      case 1:
        return '/oracle';
      case 2:
        return '/bond';
      case 3:
        return '/assessment';
      default:
        return '/';
    }
  }
}

class _MainScreenNavigatorObserver extends NavigatorObserver {
  final Function(Route<dynamic>) updateAppBarState;

  _MainScreenNavigatorObserver({required this.updateAppBarState});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    updateAppBarState(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      updateAppBarState(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      updateAppBarState(newRoute);
    }
  }
}
