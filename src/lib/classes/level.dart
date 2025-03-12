import 'package:src/classes/level_section.dart';
import 'dart:convert';

class Level {
  final int id;
  final int level;
  final String title;
  final String subtitle;
  final String imagePath;
  final List<LevelSection> sections;
  bool isCompleted;

  Level({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.sections,
    this.isCompleted = false,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      level: json['level'],
      title: json['title'],
      subtitle: json['subtitle'],
      imagePath: json['imagePath'],
      isCompleted: json['isCompleted'],
      sections:
          (json['sections'] as List)
              .map((section) => LevelSection.fromJson(section))
              .toList(),
    );
  }
}
