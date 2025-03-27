import 'package:flutter/material.dart';
import 'package:src/classes/level_section.dart';
import 'package:shimmer/shimmer.dart';

class LessonSectionCard extends StatefulWidget {
  final LevelSection section;
  final VoidCallback onTap;

  const LessonSectionCard({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  State<LessonSectionCard> createState() => _LessonSectionCardState();
}

class _LessonSectionCardState extends State<LessonSectionCard> {
  Future<void> _loadImage(String imagePath) async {
    return await precacheImage(AssetImage(imagePath), context);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    const double verticalPadding = 20.0;

    return FutureBuilder(
      future: _loadImage(widget.section.imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.none) {
          return const Center(child: Text('No data found'));
        } else if (snapshot.connectionState == ConnectionState.done) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        widget.section.imagePath,
                        height: screenHeight * 0.150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.section.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                softWrap: true,
                              ),
                              Text(
                                widget.section.subtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                strutStyle: StrutStyle(
                                  height: 1.25,
                                  forceStrutHeight: true,
                                ),
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value:
                                    widget.section.totalLessons > 0
                                        ? widget.section.completedLessons /
                                            widget.section.totalLessons
                                        : 0.25,
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color.fromARGB(255, 0, 247, 255),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Error loading image'));
        }
      },
    );
  }
}
