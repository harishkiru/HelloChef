import 'package:flutter/material.dart';
import 'package:src/screens/practice/practice_display_tile.dart';
import '../practice/practice_tile.dart';


class PracticeGrid extends StatelessWidget {
  final List<PracticeTile> items;
  const PracticeGrid({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Err handle if list is empty
    if (items.isEmpty) {
      return Center(child: Text('No exercises available.'));
    }

    // Display tiles in grid formation
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TileMaker(item: items[index]);
      },
    );
  }
}
