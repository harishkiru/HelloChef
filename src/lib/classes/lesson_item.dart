import 'package:src/classes/quiz.dart';

class LessonItem {
  final int id;
  final String title;
  final int type; // 0: content, 1: video, 2: quiz
  final String imagePath;
  final String? videoPath;
  final String? content;
  final Quiz? quiz;

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
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      imagePath: json['imagePath'],
      isCompleted: json['isCompleted'],
      content: json['content'],
      videoPath: json['videoPath'],
    );
  }
}
