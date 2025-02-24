import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/components/user_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); 
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void checkAuth() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/');
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hello Chef Home', 
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
        child: Text('Hello Chef Home Content'),
      ),
    );
  }
}