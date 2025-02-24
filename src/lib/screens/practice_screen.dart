import 'package:flutter/material.dart';
import 'package:src/components/user_profile.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: const [
          UserProfileIcon(),
        ],
      ),
      endDrawer: const UserProfileDrawer(),
      body: const Center(
        child: Text('Practice Screen'),
      ),
    );
  }
}