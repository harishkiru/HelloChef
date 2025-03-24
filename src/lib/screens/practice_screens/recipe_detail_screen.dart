import 'package:flutter/material.dart';
import 'practice_tile.dart';

class RecipeDetailScreen extends StatelessWidget {
  final PracticeTile item;
  const RecipeDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Add back button with standard behavior
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(item.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.error, size: 60, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),

              Text(
                item.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 10),

              _buildSectionHeader("Ingredients"),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      item.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "• ${ingredient['name']} - ${ingredient['quantity']}",
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: 20),

              _buildSectionHeader("Instructions"),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      item.instructions
                          .split("\n")
                          .where((step) => step.trim().isNotEmpty)
                          .map(
                            (step) =>
                                step.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                          )
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                            int stepIndex = entry.key + 1;
                            String stepText = entry.value.trim();
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Step $stepIndex \n",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                    TextSpan(text: stepText),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      // Bottom navigation bar removed as requested
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
