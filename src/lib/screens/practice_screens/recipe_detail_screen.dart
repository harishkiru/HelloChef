import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../practice_simulation/game_screen.dart';
import 'practice_tile.dart';
import 'package:src/components/common/safe_bottom_padding.dart';

class RecipeDetailScreen extends StatelessWidget {
  final PracticeTile item;
  const RecipeDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(item.title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        actions: [],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, size: 60, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(recipeName: item.title),
                          ),
                        );
                      },
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        "Start Simulation",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    if (item.youtubeUrl.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse(item.youtubeUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open the video.')),
                            );
                          }
                        },
                        icon: Icon(Icons.ondemand_video, color: Colors.white),
                        label: Text(
                          "YouTube",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.green[300] : Colors.green[800],
                  ),
                ),
                SizedBox(height: 10),
                _buildSectionHeader(context, "Ingredients"),
                _buildCard(
                  context: context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.ingredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "• ${ingredient['name']} - ${ingredient['quantity']}",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                            Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 20),
                _buildSectionHeader(context, "Instructions"),
                _buildCard(
                  context: context,
                  child: Column(
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
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                            ),
                            children: [
                              TextSpan(
                                text: "Step $stepIndex \n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.green[300]
                                      : Colors.green[800],
                                ),
                              ),
                              TextSpan(text: stepText),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SafeBottomPadding(extraPadding: 16.0, child: SizedBox(height: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.green[300] : Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
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
