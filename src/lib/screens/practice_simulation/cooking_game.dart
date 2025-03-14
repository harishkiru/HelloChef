import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'game_step.dart';

class CookingGame extends FlameGame {
  final String recipeName;
  final Function(int, int) onStepComplete;
  final Function() onGameComplete;
  final VoidCallback? onStepChanged;
  List<GameStep> steps = [];
  int currentStepIndex = -1;
  bool _isLoaded = false;

  CookingGame({
    required this.recipeName,
    required this.onStepComplete,
    required this.onGameComplete,
    this.onStepChanged,
  });

  String get currentStepText {
    if (currentStepIndex >= 0 && currentStepIndex < steps.length) {
      return steps[currentStepIndex].ingredient.replaceAll("_", " ");
    }
    return "";
  }


  @override
  Future<void> onLoad() async {
    if (_isLoaded) return;

    print("Loading game for recipe: $recipeName");

    final background = SpriteComponent()
      ..sprite = await Sprite.load('simulation_images/newbg2.png')
      ..size = size
      ..priority = -1;
    add(background);

    final String response = await rootBundle.loadString('assets/data/recipes_simulation.json');
    final List<dynamic> recipes = jsonDecode(response);
    final Map<String, dynamic>? recipe = recipes.firstWhere(
          (r) => r["strMeal"] == recipeName,
      orElse: () => {},
    );

    if (recipe == null || !recipe.containsKey("steps")) {
      print("Recipe not found or missing steps!");
      return;
    }

    final List<dynamic> stepList = recipe["steps"];
    int totalSteps = stepList.length;

    steps = stepList.map((step) {
      return GameStep.fromJson(
        step as Map<String, dynamic>,
        onStepComplete,
        totalSteps,
      );
    }).toList();

    print("Loaded ${steps.length} steps for $recipeName");
    _isLoaded = true;
    nextStep();
  }

  void nextStep() {
    if (currentStepIndex < steps.length - 1) {
      if (currentStepIndex >= 0 && contains(steps[currentStepIndex])) {
        remove(steps[currentStepIndex]);
      }
      currentStepIndex++;
      print("Moving to step ${currentStepIndex + 1} of ${steps.length}");
      print("Current step text: $currentStepText");
      add(steps[currentStepIndex]);
      onStepComplete(10, steps.length);
      onStepChanged?.call();
    } else {
      print("All steps completed for $recipeName!");


      if (currentStepIndex >= 0 && contains(steps[currentStepIndex])) {
        remove(steps[currentStepIndex]);
      }

      onGameComplete();
      onStepChanged?.call();
    }
  }


}