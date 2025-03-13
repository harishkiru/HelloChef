import 'package:flutter/material.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_components/lesson_section_card.dart';
import 'package:src/screens/lesson_screens/level_section_overview_screen.dart';

class LevelSectionScreen extends StatefulWidget {
  final Level level;

  const LevelSectionScreen({super.key, required this.level});

  @override
  State<LevelSectionScreen> createState() => _LevelSectionScreenState();
}

class _LevelSectionScreenState extends State<LevelSectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.level.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.level.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.level.sections.length,
              itemBuilder: (context, index) {
                return LessonSectionCard(
                  section: widget.level.sections[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LevelSectionOverviewScreen(
                              section: widget.level.sections[index],
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}