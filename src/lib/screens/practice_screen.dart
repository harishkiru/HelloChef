import 'package:flutter/material.dart';
import 'practice/practice_tile.dart';
import 'practice/practice_filter.dart';
import 'practice/practice_grid.dart';
import 'practice/practice_data.dart';
import 'package:src/components/user_profile.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  Difficulty selectedDifficulty = Difficulty.all;

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedDifficulty == Difficulty.all
        ? practiceTile
        : practiceTile.where((item) => item.difficulty == selectedDifficulty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: const [
          UserProfileIcon(),
        ],
      ),
      endDrawer: const UserProfileDrawer(),
      body: Column(
        children: [
          FilterOptions(
            selectedDifficulty: selectedDifficulty,
            onDifficultySelected: (difficulty) {
              setState(() {
                selectedDifficulty = difficulty;
              });
            },
          ),
          Expanded(child: PracticeGrid(items: filteredItems)),
        ],
      ),
    );
  }
}