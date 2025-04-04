import 'package:flutter/material.dart';
import 'practice_tile.dart';

class FilterOptions extends StatelessWidget {
  final Difficulty selectedDifficulty;
  final Function(Difficulty) onDifficultySelected;
  final Category selectedCategory;
  final Function(Category) onCategorySelected;

  const FilterOptions({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildDropdownBox<Difficulty>(
                  context: context,
                  value: selectedDifficulty,
                  items: Difficulty.values,
                  onChanged: (newValue) {
                    onDifficultySelected(newValue!);
                  },
                ),
                _buildFloatingLabel(context, "Difficulty"),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                _buildDropdownBox<Category>(
                  context: context,
                  value: selectedCategory,
                  items: Category.values,
                  onChanged: (newValue) {
                    onCategorySelected(newValue!);
                  },
                ),
                _buildFloatingLabel(context, "Category"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabel(BuildContext context, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      left: 14,
      top: 4,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownBox<T>({
    required BuildContext context,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      margin: EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[400]!, 
          width: 1.5
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
          dropdownColor: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                _capitalize(item.toString().split('.').last),
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: isDarkMode 
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.black,
                ),
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
