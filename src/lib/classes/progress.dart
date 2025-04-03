import 'package:src/classes/level.dart';

class Progress {
  Level level;
  int numSections;
  int numSectionsCompleted;
  double progressPercentage;

  Progress({
    required this.level,
    required this.numSections,
    required this.numSectionsCompleted,
    required this.progressPercentage,
  });
}
