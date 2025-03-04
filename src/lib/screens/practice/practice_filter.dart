import 'package:flutter/material.dart';
import 'practice_tile.dart';

class FilterOptions extends StatelessWidget {
  final Difficulty selectedDifficulty;
  final Function(Difficulty) onDifficultySelected;

  // Get filter option/state
  const FilterOptions({
    Key? key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  }) : super(key: key);

  // Create filter UI
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Difficulty.values.map((difficulty) {
          return FilterChip(
            label: Text(difficulty.name.toUpperCase()),
            selected: selectedDifficulty == difficulty,
            onSelected: (bool isSelected) {
              onDifficultySelected(isSelected ? difficulty : Difficulty.all);
            },
          );
        }).toList(),
      ),
    );
  }
}
