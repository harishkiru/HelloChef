import 'package:flutter/material.dart';
import 'practice_tile.dart';

class RecipeDetailScreen extends StatelessWidget {
  final PracticeTile item;
  const RecipeDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error, size: 60, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),

              Text(
                "Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.ingredients.map((ingredient) {
                  return Text("• ${ingredient['name']} - ${ingredient['quantity']}");
                }).toList(),
              ),

              SizedBox(height: 16),
              Text(
                "Instructions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item.instructions
                    .split("\n")
                    .where((step) => step.trim().isNotEmpty)
                    .map((step) => step.replaceFirst(RegExp(r'^\d+\.\s*'), ''))
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  int stepIndex = entry.key + 1;
                  String stepText = entry.value.trim();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Step $stepIndex\n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          TextSpan(text: stepText + "\n"),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
