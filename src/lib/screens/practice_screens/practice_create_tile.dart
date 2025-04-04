import 'package:flutter/material.dart';
import 'practice_tile.dart';
import 'recipe_detail_screen.dart';

class TileMaker extends StatelessWidget {
  final PracticeTile item;
  const TileMaker({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures the image doesn't overflow
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(item: item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section - reduced flex slightly to give more room for text
            Expanded(
              flex: 6, // Reduced from 7 to 6
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with error handling
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported, 
                        size: 50, 
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  
                  // Difficulty badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(item.difficulty, isDarkMode),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getDifficultyText(item.difficulty),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Text section - increased flex for more space
            Expanded(
              flex: 4, // Increased from 3 to 4
              child: Container(
                color: isDarkMode ? Colors.green : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced padding
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Use minimum space needed
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13, // Slightly reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        SizedBox(height: 2), // Smaller spacing
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 11, // Slightly reduced font size
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to get appropriate color for difficulty level
  Color _getDifficultyColor(Difficulty difficulty, bool isDarkMode) {
    switch (difficulty) {
      case Difficulty.easy:
        return isDarkMode ? Colors.green[800]! : Colors.green[600]!;
      case Difficulty.medium:
        return isDarkMode ? Colors.orange[800]! : Colors.orange[600]!;
      case Difficulty.hard:
        return isDarkMode ? Colors.red[800]! : Colors.red[600]!;
      default:
        return isDarkMode ? Colors.blue[800]! : Colors.blue[600]!;
    }
  }
  
  // Helper method to get appropriate text for difficulty level
  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      default:
        return 'All';
    }
  }
}
