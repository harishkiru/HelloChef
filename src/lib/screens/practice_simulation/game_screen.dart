import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../practice_screens/practice_screen.dart';
import 'cooking_game.dart';
import 'start_menu.dart';
import 'package:src/components/common/safe_bottom_padding.dart';


class GameScreen extends StatefulWidget {
  final String recipeName;

  const GameScreen({super.key, required this.recipeName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late CookingGame game;
  int score = 0;
  int stepsCompleted = 0;
  int totalSteps = 1;
  bool gameCompleted = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    resetGame();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void resetGame() {
    setState(() {
      gameCompleted = false;
      score = 0;
      stepsCompleted = 0;
      totalSteps = 1;
      game = CookingGame(
        recipeName: widget.recipeName,
        onStepComplete: updateProgress,
        onGameComplete: showCompletionBanner,
        onStepChanged: () => setState(() {}),
      );
    });
  }

  void updateProgress(int points, int stepCount) {
    setState(() {
      score += points;
      stepsCompleted += 1;
      totalSteps = stepCount;
      print("Progress: $stepsCompleted/$totalSteps");
    });
  }

  void showCompletionBanner() {
    setState(() {
      gameCompleted = true;
    });

    _confettiController.play();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "🎉 Practice Completed! Great Job!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("How to Play"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. Tilt to pour liquids."),
              Text("2. Drag to add dry ingredients."),
              Text("3. Swipe to chop/slice."),
              Text("4. Tap to sprinkle or stir."),
              Text("5. Flip or tap-hold to cook."),
              Text("6. Drag and drop to complete steps!"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Got it!"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    double progress = (totalSteps == 0) ? 0 : stepsCompleted / totalSteps;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(widget.recipeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),

      body: SafeArea(  // Added SafeArea
        child: Stack(
          children: [
            GameWidget(game: game),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.005),
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    game.currentStepText,
                    style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: screenHeight * 0.01,
              ),
            ),

            Positioned(
              bottom: screenHeight * 0.35,
              left: screenWidth * 0.30,
              child: DragTarget<String>(
                onWillAccept: (ingredient) {
                  setState(() {});
                  return true;
                },
                onLeave: (ingredient) {
                  setState(() {});
                },
                onAccept: (ingredient) {
                  if (game.currentStepIndex >= 0 && game.steps.isNotEmpty) {
                    game.steps[game.currentStepIndex].completeStep();
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    height: screenHeight * 0.10,
                    width: screenWidth * 0.20,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.transparent, width: 0),
                    ),
                  );
                },
              ),
            ),

            if (gameCompleted)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 80,
                  gravity: 0.1,
                  minBlastForce: 10,
                  maxBlastForce: 40,
                ),
              ),

            if (gameCompleted)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + screenHeight * 0.05,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
                child: SafeBottomPadding(
                  extraPadding: 12.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        stepsCompleted = (stepsCompleted + 1).clamp(0, totalSteps);
                      });

                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pop(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Back to Menu",
                      style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
