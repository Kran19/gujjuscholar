import 'package:flutter/material.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/quiz/presentation/providers/quiz_controller.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';

class QuizAttemptScreen extends ConsumerWidget {
  final int quizId;
  const QuizAttemptScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider(quizId));

    // Listen for errors and show SnackBar
    ref.listen<String?>(
      quizControllerProvider(quizId).select((s) => s.error),
      (previous, next) {
        if (next != null && next != previous) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $next")),
          );
        }
      },
    );

    // Trigger Dialog when completed
    ref.listen<bool>(
      quizControllerProvider(quizId).select((s) => s.isCompleted),
      (previous, next) {
        if (next && !(previous ?? false)) {
          final state = ref.read(quizControllerProvider(quizId));
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => QuizCompletionDialog(
              score: state.score ?? 0,
              total: state.totalQuestions ?? 0,
              quizId: quizId,
            ),
          );
        }
      },
    );

    if (quizState.isLoading && quizState.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (quizState.questions.isEmpty) {
      return Scaffold(body: Center(child: Text(quizState.error ?? "No questions found")));
    }

    final question = quizState.questions[quizState.currentQuestionIndex];
    final selectedOption = quizState.answers[question.id];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          quizState.isReviewMode ? "Review Answers" : (quizState.quizTitle ?? "Quiz"),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: quizState.isReviewMode
            ? _buildReviewList(context, ref, quizState)
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProgress(quizState),
                          const SizedBox(height: 32),
                          _buildQuestion(context, question),
                          const SizedBox(height: 32),
                          _buildOptions(ref, quizState, question, selectedOption),
                        ],
                      ),
                    ),
                  ),
                  _buildNavigation(context, ref, quizState, selectedOption),
                ],
              ),
      ),
    );
  }

  Widget _buildReviewList(BuildContext context, WidgetRef ref, QuizNotifier state) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: state.questions.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: Color(0xFFEEEFF5), thickness: 1.5),
            ),
            itemBuilder: (context, index) {
              final question = state.questions[index];
              final selectedOption = state.answers[question.id];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${index + 1}",
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuestion(context, question),
                  const SizedBox(height: 24),
                  _buildOptions(ref, state, question, selectedOption),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Close Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(QuizNotifier state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Question ${state.currentQuestionIndex + 1}/${state.questions.length}",
              style: const TextStyle(
                color: Color(0xFF4B5E7B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 20, color: Color(0xFF1565C0)),
                  SizedBox(width: 6),
                  Text(
                    state.formattedTime,
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (state.currentQuestionIndex + 1) / (state.questions.isEmpty ? 1 : state.questions.length),
            minHeight: 10,
            backgroundColor: const Color(0xFFEEEFF5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, QuestionModel question) {
    return Text(
      question.question,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildOptions(WidgetRef ref, QuizNotifier state, QuestionModel question, int? selectedOption) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = selectedOption == index;
        
        Color backgroundColor = Colors.white;
        Color borderColor = const Color(0xFFEEEFF5);
        Color textColor = const Color(0xFF4B5E7B);
        IconData? indicatorIcon;
        Color indicatorColor = Colors.transparent;

        if (state.isReviewMode) {
          if (option.isCorrect) {
            backgroundColor = const Color(0xFFE8F5E9); // Light Green
            borderColor = Colors.green;
            textColor = Colors.green[800]!;
            indicatorIcon = Icons.check_circle_rounded;
            indicatorColor = Colors.green;
          } else if (isSelected) {
            backgroundColor = const Color(0xFFFFEBEE); // Light Red
            borderColor = Colors.red;
            textColor = Colors.red[800]!;
            indicatorIcon = Icons.cancel_rounded;
            indicatorColor = Colors.red;
          }
        } else {
          if (isSelected) {
            backgroundColor = const Color(0xFFE8F0FE);
            borderColor = const Color(0xFF1565C0);
            textColor = const Color(0xFF1565C0);
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: state.isReviewMode ? null : () => ref.read(quizControllerProvider(quizId)).selectOption(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: isSelected && !state.isReviewMode ? [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: state.isReviewMode 
                            ? (indicatorIcon != null ? indicatorColor : const Color(0xFFD1D5DB))
                            : (isSelected ? const Color(0xFF1565C0) : const Color(0xFFD1D5DB)),
                        width: 2,
                      ),
                      color: isSelected && !state.isReviewMode ? const Color(0xFF1565C0) : Colors.transparent,
                    ),
                    child: indicatorIcon != null 
                        ? Icon(indicatorIcon, size: 22, color: indicatorColor)
                        : (isSelected && !state.isReviewMode 
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option.optionText,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: isSelected || (state.isReviewMode && option.isCorrect) ? FontWeight.w700 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigation(BuildContext context, WidgetRef ref, QuizNotifier state, int? selectedOption) {
    final isLast = state.currentQuestionIndex == state.questions.length - 1;
    final isLoading = state.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: state.currentQuestionIndex > 0
                    ? () => ref.read(quizControllerProvider(quizId)).previousQuestion()
                    : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Previous",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (selectedOption == null || isLoading)
                    ? null
                    : () {
                        if (state.isReviewMode) {
                          if (isLast) {
                            Navigator.pop(context);
                          } else {
                            ref.read(quizControllerProvider(quizId)).nextQuestion();
                          }
                        } else if (isLast) {
                          ref.read(quizControllerProvider(quizId)).submitQuiz();
                        } else {
                          ref.read(quizControllerProvider(quizId)).nextQuestion();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        state.isReviewMode 
                          ? (isLast ? "Close Review" : "Next")
                          : (isLast ? "Submit" : "Next"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizCompletionDialog extends StatelessWidget {
  final int score;
  final int total;
  final int quizId;

  const QuizCompletionDialog({
    super.key,
    required this.score,
    required this.total,
    required this.quizId,
  });

  @override
  Widget build(BuildContext context) {
    String getMessage() {
      double percentage = total > 0 ? (score / total) * 100 : 0;
      if (percentage >= 80) return "Excellent work, Kalp!";
      if (percentage >= 50) return "Good job, Kalp!";
      return "Keep practicing, Kalp!";
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Quiz Completed!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 32),
            const Icon(
              Icons.stars_rounded,
              size: 100,
              color: Color(0xFFFFB300), // Amber Gold
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "$score / $total",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              getMessage(),
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF4B5E7B),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to courses/list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Back to Courses",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Consumer(
                builder: (context, ref, _) => OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    ref.read(quizControllerProvider(quizId)).toggleReviewMode();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "View Answers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
