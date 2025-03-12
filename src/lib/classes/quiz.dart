class QuizQuestion {
  final String question;
  final String? imagePath;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    this.imagePath,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class Quiz {
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  
  Quiz({
    required this.title,
    required this.description,
    required this.questions,
  });
}