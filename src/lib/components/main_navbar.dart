import 'package:flutter/material.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/screens/lesson_screen.dart';
import 'package:src/screens/practice_screen.dart';

class NavigationScaffold extends StatefulWidget {
  const NavigationScaffold({super.key});

  @override
  State<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends State<NavigationScaffold> {
  int _selectedIndex = 1;

  // Pre-load all three screens.
  final List<Widget> _screens = [
    LessonScreen(), // index 0
    HomeScreen(), // index 1
    PracticeScreen(), // index 2
  ];

  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Lessons';
      case 1:
        return 'Hello Chef Home';
      case 2:
        return 'Practice';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Practice'),
        ],
      ),
    );
  }
}
