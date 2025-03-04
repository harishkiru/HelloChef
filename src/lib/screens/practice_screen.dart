import 'package:flutter/material.dart';
import '../components/user_profile.dart';
import 'practice/practice_tile.dart';
import 'practice/practice_data.dart';
import 'practice/practice_grid.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late Future<List<PracticeTile>> _practiceTilesFuture;

  @override
  void initState() {
    super.initState();
    _practiceTilesFuture = fetchPracticeTiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: const [UserProfileIcon()],
      ),
      endDrawer: const UserProfileDrawer(),
      body: FutureBuilder<List<PracticeTile>>(
        future: _practiceTilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories available'));
          }

          return PracticeGrid(items: snapshot.data!);
        },
      ),
    );
  }
}
