import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import 'slide_right_route.dart';

class CustomAppBarData {
  bool canPop;
  String currentTitle;
  VoidCallback navigateToHome;
  VoidCallback onPurchaseComplete;
  VoidCallback onBackPressed;

  CustomAppBarData({
    required this.canPop,
    required this.currentTitle,
    required this.navigateToHome,
    required this.onPurchaseComplete,
    required this.onBackPressed,
  });
}

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final CustomAppBarData data;

  const CustomAppBar({
    super.key,
    required this.data,
  });

  @override
  State<CustomAppBar> createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class CustomAppBarState extends State<CustomAppBar> {
  late CustomAppBarData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  @override
  void didUpdateWidget(CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _data = widget.data;
  }

  void update(CustomAppBarData newData) {
    setState(() {
      _data = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      automaticallyImplyLeading: false,
      leading: _data.canPop
          ? IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).primaryColor),
              onPressed: _data.onBackPressed,
            )
          : null,
      title: Text(
        _data.currentTitle,
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
          onPressed: _data.navigateToHome,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 20, 0),
          child: IconButton(
            icon: const Icon(
              Icons.settings_suggest_rounded,
              size: 24,
            ),
            onPressed: () => _navigateToSettings(context),
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
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      SlideRightRoute(
        page: SettingsScreen(
          onPurchaseComplete: _data.onPurchaseComplete,
        ),
      ),
    );
  }
}