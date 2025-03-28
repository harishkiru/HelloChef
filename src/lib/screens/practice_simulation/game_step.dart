import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:async' as dart_async;
import 'dart:ui';
import 'cooking_game.dart';
import 'dart:math';

class GameStep extends SpriteComponent with DragCallbacks, TapCallbacks {
  final String action;
  final String ingredient;
  final Function(int, int) onStepComplete;
  final int totalSteps;
  late CookingGame game;
  bool stepCompleted = false;
  bool _isPouring = false;
  bool _pourComplete = false;
  dart_async.Timer? _pourTimer;

  final Map<String, Color> ingredientColors = {
    "Sake": Colors.green,
    "Soy_Sauce": Colors.brown,
    "Sesame_Seed_Oil": Colors.orange,
    "Corn_Flour": Colors.yellow,
    "Water": Colors.blue,
    "Chilli_Powder": Colors.redAccent,
    "Rice_Vinegar": Colors.pink,
    "Brown_Sugar": Colors.brown,
  };

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
  void onTapDown(TapDownEvent event) {
    if (action == 'stir') {
      add(RotateEffect.by(1.5, EffectController(duration: 0.5)));
      completeStep();
    } else if (action == 'chop') {
      _startChop();
    } else if (action == 'sprinkle') {
      _addSprinkleEffect(position + Vector2(size.x * 0.4, size.y * 0.3), ingredientColors[ingredient]);
      completeStep();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (stepCompleted) {
      return;
    }

    if (action != 'pour' && action != 'chop') {
      add(ScaleEffect.to(Vector2(1.3, 1.3), EffectController(duration: 0.2)));
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (stepCompleted || action == 'sprinkle') {
      return;
    }

    if (action == 'pour' && !_pourComplete) {
      if (!_isPouring) {
        _startPour();
      }
      return;
    }

    if (action != 'pour') {
      position.add(event.localDelta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    add(ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.2)));

    if (action == 'pour' && _isPouring) {
      _stopPouring();
    }

    if (position.y > game.size.y * 0.4 && !_pourComplete) {
      completeStep();
    }
  }

  void _startPour() {
    _isPouring = true;
    _pourComplete = false;

    add(RotateEffect.to(0.4, EffectController(duration: 0.5, curve: Curves.easeInOut)));

    Future.delayed(const Duration(milliseconds: 500), () {
      _pourTimer = dart_async.Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _addPourEffect(position + Vector2(size.x * 0.45, size.y * 0.3), ingredientColors[ingredient]);
      });
    });

    dart_async.Timer(const Duration(milliseconds: 1500), () {
      if (!_pourComplete) {
        _stopPouring();
      }
    });
  }

  void _stopPouring() {
    if (_pourTimer != null) {
      _pourTimer!.cancel();
    }

    _isPouring = false;
    _pourComplete = true;

    add(RotateEffect.to(0, EffectController(duration: 0.3, curve: Curves.easeOut)));

    completeStep();
  }

  void _addPourEffect(Vector2 position, Color? particleColor) {
    double startY = position.y - size.y * 2.2;
    double targetY = position.y + 30;

    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 8,
          lifespan: 0.7,
          generator: (i) {
            double yOffset = lerpDouble(startY, targetY, i / 20)!;
            return AcceleratedParticle(
              acceleration: Vector2(0, 150),
              speed: Vector2(Random().nextDouble() * 10 - 5, 100),
              position: Vector2(position.x, yOffset),
              child: CircleParticle(
                radius: 3.0,
                paint: Paint()..color = particleColor ?? Colors.blueAccent.withOpacity(0.8),
              ),
            );
          },
        ),
      ),
    );
  }


  void _addSprinkleEffect(Vector2 position, Color? particleColor) {
    print("✅ Sprinkle effect triggered at: $position");

    double startY = position.y - 150;
    double endY = startY + 50;

    parent?.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 30,
          lifespan: 2.0,
          generator: (i) {
            double xOffset = Random().nextDouble() * 100 - 50;

            double yOffset = lerpDouble(startY, endY, i / 30)!;

            return AcceleratedParticle(
              acceleration: Vector2(0, 100),
              speed: Vector2(xOffset, 0),
              position: position.clone() + Vector2(0, startY - position.y),
              child: CircleParticle(
                radius: 6.0,
                paint: Paint()..color = particleColor ?? Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  void _startChop() {
    if (stepCompleted) return;

    opacity = 0.0;

    _splitIntoPieces(6);

    add(MoveEffect.by(
      Vector2(5, 0),
      EffectController(duration: 0.1, reverseDuration: 0.1, repeatCount: 2),
    ));

    Future.delayed(const Duration(milliseconds: 1000), () {
      completeStep();
    });
  }

  void _splitIntoPieces(int numPieces) {
    double pieceWidth = size.x / numPieces;
    List<SpriteComponent> pieces = [];

    for (int i = 0; i < numPieces; i++) {
      var piece = SpriteComponent(
        sprite: sprite,
        size: Vector2(pieceWidth, size.y),
        position: position + Vector2(pieceWidth * i, 0),
      );

      piece.add(MoveEffect.by(
        Vector2(Random().nextDouble() * 60 - 30, 300),
        EffectController(duration: 1.0, curve: Curves.easeOut),
      ));

      Future.delayed(const Duration(milliseconds: 500), () {
        piece.add(OpacityEffect.to(
          0,
          EffectController(duration: 0.5),
        ));
      });

      parent?.add(piece);
      pieces.add(piece);
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
