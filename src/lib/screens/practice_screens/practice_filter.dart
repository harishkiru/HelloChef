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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildDropdownBox<Difficulty>(
                  value: selectedDifficulty,
                  items: Difficulty.values,
                  onChanged: (newValue) {
                    onDifficultySelected(newValue!);
                  },
                ),
                _buildFloatingLabel("Difficulty"),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                _buildDropdownBox<Category>(
                  value: selectedCategory,
                  items: Category.values,
                  onChanged: (newValue) {
                    onCategorySelected(newValue!);
                  },
                ),
                _buildFloatingLabel("Category"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabel(String label) {
    return Positioned(
      left: 14,
      top: 4,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        color: Colors.white,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownBox<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                _capitalize(item.toString().split('.').last),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _capitalize(String text) {
    return text.replaceAll("_", " ").split(" ").map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(" ");
  }
}
