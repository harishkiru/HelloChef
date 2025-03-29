import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GamificationWidget extends StatefulWidget {
  const GamificationWidget({super.key});

  @override
  State<GamificationWidget> createState() => _GamificationWidgetState();
}

class _GamificationWidgetState extends State<GamificationWidget> {
  late ConfettiController _confettiController;
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _player = AudioPlayer();
    _player.setSource(AssetSource('sounds/level_complete.mp3'));
  }

  void levelComplete(context) {
    // Show confetti when the user completes the task
    _confettiController.play();
    _player.resume();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have completed the lesson!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    //Navigator.pop(context, true);
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
            blastDirection: -pi / 2, // 270 degrees, shooting upwards
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 300,
            gravity: 0.2, // Allows it to fall back down after reaching the top
            minBlastForce: 100, // Controls the initial speed
            maxBlastForce: 500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: screenHeight * 0.06,
            child: ElevatedButton(
              onPressed: () => levelComplete(context),
              child: Text('Complete', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void dispose() {
    _confettiController.dispose();
    _player.dispose();
    super.dispose();
  }
}
