import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GamificationWidget extends StatefulWidget {
  const GamificationWidget({super.key});

  @override
  State<GamificationWidget> createState() => _GamificationWidgetState();
}

class _GamificationWidgetState extends State<GamificationWidget>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AudioPlayer _player;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
    _player = AudioPlayer();
    _player.setSource(AssetSource('sounds/level_complete.mp3'));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void levelComplete(context) {
    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Enhanced confetti
    _confettiController.play();

    // Play sound
    _player.resume();

    // Animated dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Congratulations Dialog',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container(); // Not used but required
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'You have completed the lesson!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          '+10 XP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 300,
            gravity: 0.2, // Allows it to fall back down after reaching the top
            minBlastForce: 100, // Controls the initial speed
            maxBlastForce: 500,
            colors: const [
              Color.fromARGB(255, 255, 0, 0), // Red
              Color.fromARGB(255, 255, 128, 0), // Orange
              Color.fromARGB(255, 255, 255, 0), // Yellow
              Color.fromARGB(255, 0, 255, 0), // Green
              Color.fromARGB(255, 0, 128, 255), // Sky Blue
              Color.fromARGB(255, 0, 0, 255), // Blue
              Color.fromARGB(255, 128, 0, 255), // Purple
              Color.fromARGB(255, 255, 0, 255), // Magenta
              Color.fromARGB(255, 255, 20, 147), // Deep Pink
              Color.fromARGB(255, 0, 255, 255), // Cyan
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: () => levelComplete(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Complete', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
