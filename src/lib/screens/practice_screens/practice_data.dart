import 'dart:convert';
import 'package:flutter/services.dart';
import 'practice_tile.dart';

Future<List<PracticeTile>> loadPracticeTiles() async {
  final jsonString = await rootBundle.loadString('assets/data/recipes.json');
  final Map<String, dynamic> jsonData = jsonDecode(jsonString);

  List<dynamic> meals = jsonData['meals'];

  return meals.map((meal) => PracticeTile.fromJson(meal)).toList();
}




