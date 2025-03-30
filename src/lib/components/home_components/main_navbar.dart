//// filepath: c:/Users/Harsh/4080finalproject/src/lib/components/main_navbar.dart
library;

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
  int _selectedIndex = 1; // Home tab is the default

  // Pre-load all three screens.
  final List<Widget> _screens = [
    LessonScreen(), // index 0
    HomeScreen(), // index 1
    PracticeScreen(), // index 2
  ];

  @override
  void initState() {
    super.initState();
    // Register the callback with NavigationService
    NavigationService().changeTabCallback = (index) {
      setState(() {
        _selectedIndex = index;
      });
    };
  }

  // Handle back button press
  // Future<bool> _onWillPop() async {
  //   // If we're not on the home screen, navigate to home
  //   if (_selectedIndex != 1) {
  //     setState(() {
  //       _selectedIndex = 1; // Go to home screen
  //     });
  //     return false; // Don't exit the app
  //   }

  //   // If we're on the home screen, show exit confirmation
  //   return await showDialog<bool>(
  //         context: context,
  //         builder:
  //             (context) => AlertDialog(
  //               title: Text('Exit App'),
  //               content: Text('Are you sure you want to exit?'),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () {
  //                     SystemNavigator.pop(); // This will exit the app
  //                     Navigator.of(context).pop(true);
  //                   },
  //                   child: Text('Yes', style: TextStyle(color: Colors.green)),
  //                 ),
  //                 TextButton(
  //                   onPressed: () => Navigator.of(context).pop(false),
  //                   child: Text('No', style: TextStyle(color: Colors.green)),
  //                 ),
  //               ],
  //             ),
  //       ) ??
  //       false;
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents back navigation
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
