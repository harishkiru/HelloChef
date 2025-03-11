enum Difficulty { all, easy, medium, hard }
enum Category { all, chicken, seafood, beef, vegetarian }

class PracticeTile {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String instructions;
  final List<Map<String, String>> ingredients;
  final Difficulty difficulty;
  final Category category;

  PracticeTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.instructions,
    required this.ingredients,
    required this.difficulty,
    required this.category,
  });

  factory PracticeTile.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> parsedIngredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        parsedIngredients.add({'name': ingredient, 'quantity': measure ?? ''});
      }
    }

    return PracticeTile(
      imageUrl: json['strMealThumb'] ?? '',
      title: json['strMeal'] ?? 'Unknown',
      subtitle: json['strCategory'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? 'No instructions provided.',
      ingredients: parsedIngredients,
      difficulty: _mapDifficulty(json['difficulty']),
      category: _mapCategory(json['strCategory']),
    );
  }
}

Difficulty _mapDifficulty(String? difficulty) {
  switch (difficulty?.toLowerCase()) {
    case 'easy':
      return Difficulty.easy;
    case 'medium':
      return Difficulty.medium;
    case 'hard':
      return Difficulty.hard;
    default:
      return Difficulty.all;
  }
}

Category _mapCategory(String? category) {
  switch (category?.toLowerCase()) {
    case 'chicken':
      return Category.chicken;
    case 'seafood':
      return Category.seafood;
    case 'beef':
      return Category.beef;
    case 'vegetarian':
      return Category.vegetarian;
    default:
      return Category.all;
  }
}
