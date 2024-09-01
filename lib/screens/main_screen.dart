import 'package:flutter/material.dart';
import '../global_key.dart';
import '../helpers/constants.dart';
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
  bool _canPop = false;
  String _currentTitle = CompatibilityTexts.homeTitle;
  late final AppRouter _appRouter;
  late final PageController _pageController;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _appRouter = AppRouter(
      navigatorKey: navigatorKey,
      onNavigate: _navigateTo,
      observer: _MainScreenNavigatorObserver(
        updateCanPop: _updateCanPop,
        updateTitle: _updateTitle,
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
      _currentTitle = title ?? _appRouter.getRouteTitle(route);
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

  void _updateCanPop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _canPop =
            _navigatorKeys[_selectedIndex].currentState?.canPop() ?? false;
      });
    });
  }

  void _updateTitle(Route<dynamic> route) {
    if (route.settings.name != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentTitle = _appRouter.getRouteTitle(route.settings.name!);
          });
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _currentTitle = _getTitleForIndex(index);
    });
    _pageController.jumpToPage(index);
    // Reset the navigation stack for the selected tab
    _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        data: CustomAppBarData(
          canPop: _canPop,
          currentTitle: _currentTitle,
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
            _currentTitle = _getTitleForIndex(index);
          });
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 1),
        child: SafeArea(
          child: NavBar(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
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
  final VoidCallback updateCanPop;
  final Function(Route<dynamic>) updateTitle;

  _MainScreenNavigatorObserver({
    required this.updateCanPop,
    required this.updateTitle,
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    updateCanPop();
    if (route.settings.name != null) {
      updateTitle(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    updateCanPop();
    if (previousRoute != null && previousRoute.settings.name != null) {
      updateTitle(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    updateCanPop();
    if (newRoute != null && newRoute.settings.name != null) {
      updateTitle(newRoute);
    }
  }
}
