import 'package:src/classes/quiz.dart';

class LessonItem {
  final int id;
  final String title;
  final int type;
  final String imagePath;
  final String? videoPath;
  final String? content;
  final Quiz? quiz;
  final int? quizId;
  final List<Map<String, dynamic>>? buttonDetails;
  final String? description;

  bool isCompleted;

  LessonItem({
    required this.id,
    required this.title,
    required this.type,
    required this.imagePath,
    required this.isCompleted,
    this.videoPath,
    this.content,
    this.quiz,
    this.quizId,
    this.buttonDetails,
    this.description,
  });
}
