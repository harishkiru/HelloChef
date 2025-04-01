import 'package:flutter/material.dart';
import 'cooking_game.dart';
import 'start_menu.dart';

void main() {
  runApp(const CookingGameApp());
}

class CookingGameApp extends StatelessWidget {
  const CookingGameApp({super.key});

  static CookingGame? _gameInstance;

  static CookingGame getGameInstance(
      String recipeName, Function(int, int) onStepComplete, Function() onGameComplete) {
    if (_gameInstance == null || _gameInstance!.recipeName != recipeName) {
      print("Creating new game instance for $recipeName");
      _gameInstance = CookingGame(
        recipeName: recipeName,
        onStepComplete: onStepComplete,
        onGameComplete: onGameComplete,
      );
    } else {
      print("Reusing existing game instance for $recipeName");
    }
    return _gameInstance!;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cooking Simulator',
      theme: ThemeData.dark(),
      home: const StartMenuScreen(),
    );
  }
}
