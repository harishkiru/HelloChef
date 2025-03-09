import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:src/services/copy_asset.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl; // pass asset path like "assets/videos/video.mp4"

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool _playerInitialized = false;

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
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(controller: controller),
      ),
    );
  }
}
