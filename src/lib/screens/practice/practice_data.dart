import 'dart:convert';
import 'package:http/http.dart' as http;
import 'practice_tile.dart';

Future<List<PracticeTile>> fetchPracticeTiles() async {
  final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List categories = data['categories'];

    return categories.map((category) {
      return PracticeTile(
        imageUrl: category['strCategoryThumb'],
        title: category['strCategory'],
        subtitle: "Filler", //category['strCategoryDescription'],
        difficulty: Difficulty.medium,
      );
    }).toList();
  } else {
    throw Exception('Failed to load meal categories');
  }
}
