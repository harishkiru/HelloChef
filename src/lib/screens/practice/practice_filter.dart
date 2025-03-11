import 'package:flutter/material.dart';
import 'practice_tile.dart';

class FilterOptions extends StatelessWidget {
  final Difficulty selectedDifficulty;
  final Function(Difficulty) onDifficultySelected;

  final Category selectedCategory;
  final Function(Category) onCategorySelected;

  const FilterOptions({
    Key? key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: Difficulty.values.map((difficulty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(difficulty == Difficulty.all ? "All" : difficulty.name.toUpperCase()),
                          selected: selectedDifficulty == difficulty,
                          onSelected: (bool isSelected) {
                            onDifficultySelected(isSelected ? difficulty : Difficulty.all);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  top: -10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    color: Colors.white,
                    child: Text(
                      "Difficulty",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField<Category>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                items: Category.values.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name.toUpperCase(), style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (Category? newCategory) {
                  if (newCategory != null) {
                    onCategorySelected(newCategory);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
