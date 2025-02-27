enum Difficulty { all, easy, medium, hard }

class PracticeTile {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Difficulty difficulty;

  // Constructor [if data migrated to DB]
  PracticeTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.difficulty,
  });
}