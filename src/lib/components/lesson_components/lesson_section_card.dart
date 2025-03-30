import 'package:flutter/material.dart';
import 'package:src/classes/level_section.dart';

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

class _LessonSectionCardState extends State<LessonSectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  Future<void> _loadImage(String imagePath) async {
    return await precacheImage(AssetImage(imagePath), context);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    const double verticalPadding = 20.0;
    final bool isCompleted =
        widget.section.completedLessons >= widget.section.totalLessons;
    final double progressValue =
        widget.section.totalLessons > 0
            ? widget.section.completedLessons / widget.section.totalLessons
            : 0.25;

    return FutureBuilder(
      future: _loadImage(widget.section.imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.none) {
          return const Center(child: Text('No data found'));
        } else if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTapDown: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isPressed = true;
                  _animationController.forward();
                });
              });
            },
            onTapUp: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isPressed = false;
                  _animationController.reverse();
                });
              });
              widget.onTap();
            },
            onTapCancel: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _isPressed = false;
                  _animationController.reverse();
                });
              });
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(
                      verticalPadding,
                      10,
                      verticalPadding,
                      20,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.shade700 : Colors.green,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isCompleted ? Colors.yellow : Colors.black,
                        width: isCompleted ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isPressed ? Colors.black38 : Colors.black12,
                          offset:
                              _isPressed
                                  ? const Offset(2, 2)
                                  : const Offset(4, 4),
                          blurRadius: _isPressed ? 2.0 : 4.0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                widget.section.imagePath,
                                height: screenHeight * 0.150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.section.title,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(1, 1),
                                            blurRadius: 3.0,
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ],
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
                                      strutStyle: const StrutStyle(
                                        height: 1.25,
                                        forceStrutHeight: true,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          "${(progressValue * 100).toInt()}%",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: progressValue,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    isCompleted
                                                        ? Colors.yellow
                                                        : const Color.fromARGB(
                                                          255,
                                                          0,
                                                          247,
                                                          255,
                                                        ),
                                                  ),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Completion badge
                        if (isCompleted)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'COMPLETED',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('Error loading image'));
        }
      },
    );
  }
}
