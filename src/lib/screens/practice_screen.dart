import 'package:flutter/material.dart';
import 'practice/practice_tile.dart' as tile;
import 'practice/practice_filter.dart' as filter;
import 'practice/practice_grid.dart';
import 'practice/practice_data.dart';
import 'package:src/components/user_profile.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  tile.Difficulty selectedDifficulty = tile.Difficulty.all;
  tile.Category selectedCategory = tile.Category.all;
  late Future<List<tile.PracticeTile>> _practiceTilesFuture;

  @override
  void initState() {
    super.initState();
    _practiceTilesFuture = loadPracticeTiles();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<tile.PracticeTile>>(
        future: _practiceTilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes available.'));
          }

          final practiceTile = snapshot.data!;


          final filteredItems = practiceTile.where((item) {
            final matchesDifficulty =
                selectedDifficulty == tile.Difficulty.all || item.difficulty == selectedDifficulty;
            final matchesCategory =
                selectedCategory == tile.Category.all || item.category == selectedCategory;
            return matchesDifficulty && matchesCategory;
          }).toList();

          return Column(
            children: [
              filter.FilterOptions(
                selectedDifficulty: selectedDifficulty,
                onDifficultySelected: (difficulty) {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                },
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
              Expanded(child: PracticeGrid(items: filteredItems)),
            ],
          );
        },
      ),
    );
  }
}
