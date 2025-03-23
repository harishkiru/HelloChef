import 'package:flutter/material.dart';
import 'practice_create_tile.dart';
import 'practice_tile.dart';

class PracticeGrid extends StatelessWidget {
  final List<PracticeTile> items;
  const PracticeGrid({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No exercises available for this difficulty.'));
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8, // Adjusted for the new flex ratio
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TileMaker(item: items[index]);
      },
    );
  }
}
