import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/lesson_section.dart';
import 'package:src/classes/level.dart';

class LessonScreen extends StatefulWidget {
  LessonScreen({super.key});

  List<Level> levels = [];

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
