import 'package:flutter/material.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';
import 'package:edustream/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_attempt_screen.dart';

class QuizzesTabWidget extends StatelessWidget {
  final List<QuizModel> quizzes;

  const QuizzesTabWidget({super.key, required this.quizzes});

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No quizzes available yet.',
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return QuizCard(
          quiz: quiz,
          onStart: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizAttemptScreen(quizId: int.tryParse(quiz.id) ?? 0),
              ),
            );
          },
        );
      },
    );
  }
}
