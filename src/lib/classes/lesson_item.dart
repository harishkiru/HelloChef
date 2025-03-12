class LessonItem {
  final int id;
  final String title;
  final int type;
  final String imagePath;
  final String? videoPath;
  final String? content;

  bool isCompleted;

  LessonItem({
    required this.id,
    required this.title,
    required this.type,
    required this.imagePath,
    required this.isCompleted,
    this.videoPath,
    this.content,
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
