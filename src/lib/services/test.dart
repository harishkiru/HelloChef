import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Test());
}

class Test extends StatelessWidget {
  Test() {
    final player = AudioPlayer();
    player.play(AssetSource('sounds/rank_up.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
