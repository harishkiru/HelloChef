import 'package:flutter/material.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/components/lesson_item_card.dart';

class LevelSectionOverviewScreen extends StatefulWidget {
  final LevelSection section;

  const LevelSectionOverviewScreen({super.key, required this.section});

  @override
  State<LevelSectionOverviewScreen> createState() =>
      _LevelSectionOverviewScreenState();
}

class _LevelSectionOverviewScreenState
    extends State<LevelSectionOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.section.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.section.lessons.length,
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
              itemBuilder: (context, index) {
                return LessonItemCard(
                  lessonItem: widget.section.lessons[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}