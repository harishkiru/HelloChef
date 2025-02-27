import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isFullScreen = false; // new flag for full screen mode

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize()
          .then((_) {
            setState(() {});
          })
          .catchError((e) {
            print("Error initializing video player: $e");
          });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      final Size screenSize = MediaQuery.of(context).size;
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child:
              _controller.value.isInitialized
                  ? Container(
                    width: screenSize.width,
                    height: screenSize.height,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                  : const Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      // Windowed mode: white background with AppBar and progress bar
      return Scaffold(
        appBar: AppBar(
          title: const Text("Video Player"),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () {
                setState(() {
                  _isFullScreen = true;
                });
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Center(
                  child:
                      _controller.value.isInitialized
                          ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                          : const CircularProgressIndicator(),
                ),
              ),
            ),
            // Progress bar
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
