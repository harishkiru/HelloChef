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
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.transparent,
          child: TileMaker(item: items[index]),
        );
      },
    );
  }
}
