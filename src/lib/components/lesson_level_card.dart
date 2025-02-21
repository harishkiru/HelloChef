import 'package:flutter/material.dart';
import 'package:src/classes/level.dart';

class LessonLevelCard extends StatefulWidget {
  final Level level;
  final VoidCallback onTap;

  const LessonLevelCard({super.key, required this.level, required this.onTap});

  @override
  State<LessonLevelCard> createState() => _LessonLevelCardState();
}

class _LessonLevelCardState extends State<LessonLevelCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(60, 10, 60, 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(4, 4),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                    child: Image.asset(
                      widget.level.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  widget.level.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.level.subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
