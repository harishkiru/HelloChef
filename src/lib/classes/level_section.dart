import 'package:src/classes/lesson_item.dart';

class LevelSection {
  final int id;
  final String title;
  final String subtitle;
  final String imagePath;
  final List<LessonItem> lessons;
  int completedLessons;
  late int totalLessons;
  LevelSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.lessons,
    required this.completedLessons,
  }) {
    totalLessons = lessons.length;
    for (var lesson in lessons) {
      if (lesson.isCompleted) {
        completedLessons++;
      }
    }
  }

  factory LevelSection.fromJson(Map<String, dynamic> json) {
    return LevelSection(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      imagePath: json['imagePath'],
      completedLessons: json['completedLessons'],
      lessons:
          (json['lessons'] as List)
              .map((lesson) => LessonItem.fromJson(lesson))
              .toList(),
    );
  }
}
