import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> copyAsset(String assetPath, String filename) async {
  final byteData = await rootBundle.load(assetPath);
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$filename');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file.path;
}
