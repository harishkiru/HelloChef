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
    final double screenHeight = MediaQuery.of(context).size.height;
    const double verticalPadding = 20.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          verticalPadding,
          10,
          verticalPadding,
          20,
        ),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(4, 4),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
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
                          height: screenHeight * 0.150,
                          fit: BoxFit.cover,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 10.0,
              bottom: 10.0,
              child: Icon(
                widget.level.isCompleted
                    ? Icons.check_circle_sharp
                    : Icons.circle_outlined,
                color:
                    widget.level.isCompleted
                        ? const Color.fromARGB(255, 0, 247, 255)
                        : Colors.white,
                size: 40.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
