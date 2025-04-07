import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../practice_simulation/game_step.dart';

class CookingGame extends FlameGame {
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(true);
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
    return "Get ready to start cooking!";
  }

  Future<Sprite> _loadSprite(String ingredient) async {
    final url =
        'https://www.themealdb.com/images/ingredients/${ingredient.replaceAll(" ", "%20")}.png';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final ui.Image image = await _decodeImage(response.bodyBytes);
        return Sprite(image);
      }
    } catch (e) {
      print("Failed to preload image for $ingredient: $e");
    }

    return await Sprite.load('simulation_images/default.png');
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  Future<void> onLoad() async {
    isLoadingNotifier.value = true;

    if (_isLoaded) return;

    print("Loading game for recipe: $recipeName");

    final background = SpriteComponent()
      ..sprite = await Sprite.load('simulation_images/newbg2.png')
      ..size = size
      ..priority = -1;
    add(background);

    final String response =
    await rootBundle.loadString('assets/data/recipes_simulation.json');
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
    steps = await Future.wait(stepList.map((step) async {
      final sprite = await _loadSprite(step["ingredient"]);
      return GameStep(
        action: step["action"],
        ingredient: step["ingredient"],
        particleColor: step["particleColor"],
        onStepComplete: onStepComplete,
        totalSteps: stepList.length,
        preloadedSprite: sprite,
      );
    }));


    print("Loaded ${steps.length} steps for $recipeName");
    _isLoaded = true;
    currentStepIndex = 0;
    add(steps[currentStepIndex]);
    onStepChanged?.call();
    isLoadingNotifier.value = false;
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

      onStepComplete(10, steps.length);
      onGameComplete();
      onStepChanged?.call();
    }
  }
}
