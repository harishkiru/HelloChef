class Level {
  final int id;
  final int level;
  final String title;
  final String subtitle;
  final String imagePath;
  bool isCompleted;

  Level({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.isCompleted = false,
  });
}
