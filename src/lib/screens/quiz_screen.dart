import 'package:flutter/material.dart';
import 'package:src/classes/quiz.dart';
import 'package:src/components/user_profile.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool answered = false;
  int? selectedAnswerIndex;
  
  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.green,
        actions: const [
          UserProfileIcon(),
        ],
      ),
      endDrawer: const UserProfileDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress info
              Text(
                'Question ${currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / widget.quiz.questions.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              
              const SizedBox(height: 20),
              
              // Question
              Text(
                question.question,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 16),
              
              // Image if available
              if (question.imagePath != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(question.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
              const SizedBox(height: 24),
              
              // Options
              ...List.generate(question.options.length, (index) {
                final isSelected = selectedAnswerIndex == index;
                final isCorrect = answered && index == question.correctAnswerIndex;
                final isWrong = answered && isSelected && index != question.correctAnswerIndex;
                
                Color? backgroundColor;
                if (answered) {
                  if (isCorrect) {
                    backgroundColor = Colors.green.shade100;
                  } else if (isWrong) {
                    backgroundColor = Colors.red.shade100;
                  }
                } else if (isSelected) {
                  backgroundColor = Colors.blue.shade100;
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: answered ? null : () {
                      setState(() {
                        selectedAnswerIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.blue : Colors.grey.shade200,
                            ),
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (answered) Icon(
                            isCorrect ? Icons.check_circle : (isWrong ? Icons.cancel : null),
                            color: isCorrect ? Colors.green : (isWrong ? Colors.red : null),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Submit button or Next button
              ElevatedButton(
                onPressed: selectedAnswerIndex == null ? null : () {
                  if (!answered) {
                    setState(() {
                      answered = true;
                      if (selectedAnswerIndex == question.correctAnswerIndex) {
                        score++;
                      }
                    });
                  } else {
                    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        answered = false;
                        selectedAnswerIndex = null;
                      });
                    } else {
                      // Quiz finished
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Quiz Completed'),
                          content: Text(
                            'Your score: $score/${widget.quiz.questions.length}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Go back to lessons
                              },
                              child: const Text('Finish', style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  answered
                      ? (currentQuestionIndex < widget.quiz.questions.length - 1 ? 'Next Question' : 'Finish Quiz')
                      : 'Submit Answer',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}