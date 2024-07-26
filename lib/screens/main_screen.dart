import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<CustomAppBarState> _appBarKey =
      GlobalKey<CustomAppBarState>();
  bool _fromPurchase = false;
  bool _canPop = false;
  String _currentTitle = '';
  late final AppRouter _appRouter;
  late final CustomAppBar _appBar;
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
      _currentTitle = '';
      _updateCustomAppBar();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar,
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
