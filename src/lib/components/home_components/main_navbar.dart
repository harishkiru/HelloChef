import 'package:flutter/material.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/screens/lesson_screens/lesson_screen.dart';
import 'package:src/screens/practice_screens/practice_screen.dart';
import 'package:src/services/navigation_service.dart';

class NavigationScaffold extends StatefulWidget {
  const NavigationScaffold({super.key});

  @override
  State<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends State<NavigationScaffold> {
  int _selectedIndex = 1;

  // pre-load all three screens.
  final List<Widget> _screens = [
    LessonScreen(), // index 0
    HomeScreen(), // index 1
    PracticeScreen(), // index 2
  ];

  @override
  void initState() {
    super.initState();
    NavigationService().changeTabCallback = (index) {
      setState(() {
        _selectedIndex = index;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevents back navigation
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
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
            BottomNavigationBarItem(
              icon: Icon(Icons.kitchen),
              label: 'Practice',
            ),
          ],
        ),
      ),
    );
  }
}
