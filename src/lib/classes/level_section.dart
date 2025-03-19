import 'package:src/classes/lesson_item.dart';

class LevelSection {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath;
  int completedLessons;
  final int totalLessons;
  LevelSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.completedLessons,
    required this.totalLessons,
  });
}
