import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/services/copy_asset.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl; // pass asset path like "assets/videos/video.mp4"
  final LessonItem lessonItem;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.lessonItem,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool _playerInitialized = false;

  void _onComplete(context) {
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final filePath = await copyAsset(widget.videoUrl, 'video.mp4');
    player.open(Media(filePath));
    setState(() {
      _playerInitialized = true;
    });
  }

  //   Future<bool> _requestPermission() async {
  //   // Video permissions.
  //   if (await Permission.videos.isDenied ||
  //       await Permission.videos.isPermanentlyDenied) {
  //     final state = await Permission.videos.request();
  //     if (!state.isGranted) {
  //       return true;
  //     }
  //   }
  //   // Audio permissions.
  //   if (await Permission.audio.isDenied ||
  //       await Permission.audio.isPermanentlyDenied) {
  //     final state = await Permission.audio.request();
  //     if (!state.isGranted) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green, centerTitle: true),

      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.lessonItem.title,
              style: TextStyle(
                fontSize: 26,
                color: const Color.fromARGB(255, 26, 23, 23),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(controller: controller),
              ),
            ),
            SizedBox(height: screenHeight * 0.3),
            Container(
              width: double.infinity,
              height: screenHeight * 0.075,
              margin: EdgeInsets.fromLTRB(8, 8, 8, 40),

              child: ElevatedButton(
                onPressed: () => _onComplete(context),
                child: Text('Complete', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
