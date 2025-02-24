import 'package:src/classes/lesson_item.dart';

class LevelSection {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath;
  final List<LessonItem> lessons;
  int completedLessons = 0;
  late int totalLessons;
  LevelSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.lessons,
  }) {
    this.totalLessons = lessons.length;
  }
}
