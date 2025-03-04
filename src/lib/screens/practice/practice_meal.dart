import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../practice/practice_tile.dart';
import '../practice/practice_create_tile.dart';

class PracticeRecipe extends StatefulWidget {
  final PracticeTile item;
  const PracticeRecipe({Key? key, required this.item}) : super(key: key);

  @override
  _PracticeRecipeState createState() => _PracticeRecipeState();
}

class _PracticeRecipeState extends State<PracticeRecipe> {
  late Future<List<PracticeTile>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = fetchMealsByCategory(widget.item.title);
  }

  Future<List<PracticeTile>> fetchMealsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List meals = data['meals'];

      return meals.map((meal) {
        return PracticeTile(
          imageUrl: meal['strMealThumb'],
          title: meal['strMeal'],
          subtitle: 'Tap to view details',
          difficulty: Difficulty.medium, //CHANGE
        );
      }).toList();
    } else {
      throw Exception('Failed to load meals for category: $category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<PracticeTile>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Failed to load meals'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No meals available for this category'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return TileMaker(item: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}
