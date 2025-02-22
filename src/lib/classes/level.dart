import 'package:src/classes/level_section.dart';

class Level {
  final int id;
  final int level;
  final String title;
  final String subtitle;
  final String imagePath;
  final List<LevelSection> sections;
  bool isCompleted;

  int completedSections = 0;

  Level({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.sections,
    this.isCompleted = false,
  });
}
