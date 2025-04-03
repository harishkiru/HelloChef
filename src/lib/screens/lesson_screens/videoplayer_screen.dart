import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/services/copy_asset.dart';
import 'package:src/components/common/safe_bottom_padding.dart'; // Add this import
import 'package:src/components/common/gamification_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl; // pass asset path like "assets/videos/video.mp4"
  final LessonItem lessonItem;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonItem,
  });

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final filePath = await copyAsset(widget.videoUrl, 'video.mp4');

    try {
      await player.open(Media(filePath));
    } catch (e) {
      print('Error opening video: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          widget.lessonItem.title,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                widget.lessonItem.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Video(controller: controller),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Description:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.lessonItem.content ??
                    "Watch the video to learn new cooking techniques.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Spacer(), // Use spacer instead of fixed height
              // Replace fixed margin with SafeBottomPadding
              SafeBottomPadding(
                extraPadding: 16.0,
                child: Container(
                  width: double.infinity,
                  height: 50, // Fixed reasonable height
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: GamificationWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
