import 'package:flutter/material.dart';
import '../auth_wrapper.dart';
import '../repositories/firestore_fortune_content_repository.dart';
import '../repositories/firestore_user_repository.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'fortune_tell_screen.dart';
import 'shop_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  final _fortuneContentRepository = FirestoreFortuneContentRepository();
  final _userService = UserService(FirestoreUserRepository());

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      FortuneTellScreen(
        fortuneContentRepository: _fortuneContentRepository,
        userService: _userService,
      ),
      const ShopScreen(),
    ];
  }

  static const List<String> _titles = [
    'Home',
    'Doragle',
    'Shop',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleSignOut(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _titles[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star),
            label: _titles[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: _titles[2],
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
