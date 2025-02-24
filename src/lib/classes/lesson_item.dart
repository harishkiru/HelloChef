class LessonItem {
  final int id;
  final String title;
  final int type;
  final String imagePath;

  final String? videoPath;
  final String? content;

  bool isCompleted = false;

  LessonItem({
    required this.id,
    required this.title,
    required this.type,
    required this.imagePath,
    required this.isCompleted,
    this.videoPath,
    this.content,
  });
}
