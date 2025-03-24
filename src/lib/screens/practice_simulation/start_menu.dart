import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'main.dart';

class StartMenuScreen extends StatelessWidget {
  const StartMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cooking Simulator',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "How to Play",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "1. Drag ingredients to the cooking pot.\n"
                        "2. Follow the instructions at the top.\n"
                        "3. Complete all steps to finish the recipe!\n"
                        "4. Have fun and learn to cook!",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select a Recipe to Simulate",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 15),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    final game = CookingGameApp.getGameInstance(
                      "Kung Pao Chicken",
                          (points, total) => null,
                          () {},
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameScreen(recipeName: "Kung Pao Chicken")),
                    );
                  },
                  child: const Text(
                    "Start Cooking Kung Pao Chicken",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Removed the floating action button
    );
  }
}
