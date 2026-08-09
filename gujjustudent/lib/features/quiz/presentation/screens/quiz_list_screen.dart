import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/core/constants/app_colors.dart';
import 'package:edustream/features/explore/presentation/providers/explore_providers.dart';
import 'package:edustream/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:edustream/features/explore/data/models/explore_models.dart';
import 'package:edustream/features/explore/data/models/explore_subjects.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';
import 'package:edustream/features/quiz/presentation/screens/quiz_attempt_screen.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  @override
  Widget build(BuildContext context) {
    final quizHubAsync = ref.watch(quizHubProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 32),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.leaderboard_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Quiz Hub 🎯",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Test your knowledge, beat your best score!",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // "My Quizzes" and Filter Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Quizzes",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Icon(Icons.filter_list_rounded, color: AppColors.primary),
                ],
              ),
            ),

            // Consolidated Quiz Hub Data
            quizHubAsync.when(
              data: (categoriesJson) {
                if (categoriesJson.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "No quizzes available yet",
                            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Check back later for new tests!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: categoriesJson.map((catJson) {
                      final category = CategoryModel.fromJson(catJson as Map<String, dynamic>);
                      final coursesJson = catJson['courses'] as List? ?? [];
                      return _CategoryQuizSection(
                        category: category,
                        coursesJson: coursesJson,
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        "Error: $err",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.refresh(quizHubProvider),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CategoryQuizSection extends StatelessWidget {
  final CategoryModel category;
  final List<dynamic> coursesJson;

  const _CategoryQuizSection({
    required this.category,
    required this.coursesJson,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Divider(
                color: AppColors.primary.withValues(alpha: 0.25),
                thickness: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...coursesJson.map((courseJson) {
          final course = CourseModel.fromJson(courseJson as Map<String, dynamic>);
          final subjectsJson = courseJson['subjects'] as List? ?? [];
          return _CourseSection(
            course: course,
            subjectsJson: subjectsJson,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CourseSection extends StatelessWidget {
  final CourseModel course;
  final List<dynamic> subjectsJson;

  const _CourseSection({
    required this.course,
    required this.subjectsJson,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              course.name,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...subjectsJson.map((subjectJson) {
          final subject = SubjectModel.fromJson(subjectJson as Map<String, dynamic>);
          final quizzesJson = subjectJson['quizzes'] as List? ?? [];
          return _SubjectQuizList(
            subject: subject,
            quizzesJson: quizzesJson,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SubjectQuizList extends StatelessWidget {
  final SubjectModel subject;
  final List<dynamic> quizzesJson;

  const _SubjectQuizList({
    required this.subject,
    required this.quizzesJson,
  });

  @override
  Widget build(BuildContext context) {
    final quizzes = quizzesJson.map((q) => QuizModel.fromJson(q as Map<String, dynamic>)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              subject.name,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...quizzes.map((quiz) {
            return QuizCard(
              quiz: quiz,
              onStart: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizAttemptScreen(quizId: int.tryParse(quiz.id) ?? 0),
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
      ],
    );
  }
}
