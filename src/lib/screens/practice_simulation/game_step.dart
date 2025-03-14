import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/animation.dart';
import 'cooking_game.dart';

class GameStep extends SpriteComponent with DragCallbacks {
  final String action;
  final String ingredient;
  final Function(int, int) onStepComplete;
  final int totalSteps;
  late CookingGame game;
  bool stepCompleted = false;

  GameStep({
    required this.action,
    required this.ingredient,
    required this.onStepComplete,
    required this.totalSteps,
  });

  factory GameStep.fromJson(Map<String, dynamic> json, Function(int, int) onStepComplete, int totalSteps) {
    return GameStep(
      action: json["action"],
      ingredient: json["ingredient"],
      onStepComplete: onStepComplete,
      totalSteps: totalSteps,
    );
  }

  @override
  Future<void> onLoad() async {
    game = findGame() as CookingGame;
    double screenWidth = game.size.x;
    double screenHeight = game.size.y;

    sprite = await Sprite.load('simulation_images/${ingredient.toLowerCase().replaceAll(" ", "_")}.png');

    size = Vector2(screenWidth * 0.250, screenWidth * 0.250);

    position = Vector2(screenWidth * -0.02, screenHeight * 0.28);

  }



  @override
  void onDragStart(DragStartEvent event) {
    add(ScaleEffect.to(Vector2(1.3, 1.3), EffectController(duration: 0.2)));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    add(ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.2)));
    if (position.y > game.size.y * 0.4) {
      completeStep();
    } else {
      add(MoveEffect.to(Vector2(200, 200), EffectController(duration: 0.5, curve: Curves.easeOut)));
    }
  }

  void completeStep() {
    if (stepCompleted) return;

    stepCompleted = true;
    print("Step completed: $action on $ingredient");

    add(ScaleEffect.to(Vector2(1.6, 1.6), EffectController(duration: 0.3, reverseDuration: 0.3)));

    Future.delayed(const Duration(milliseconds: 600), () {
      removeFromParent();
      game.nextStep();
    });
  }

}