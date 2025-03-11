import 'package:src/classes/quiz.dart';

class LessonItem {
  final int id;
  final String title;
  final int type; // 0: content, 1: video, 2: quiz
  final String imagePath;

  final String? videoPath;
  final String? content;
  final Quiz? quiz;

  bool isCompleted = false;

  LessonItem({
    required this.id,
    required this.title,
    required this.type,
    required this.imagePath,
    required this.isCompleted,
    this.videoPath,
    this.content,
    this.quiz,
  });
}
