import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/quiz/data/quiz_repository.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';

final quizRepositoryProvider = Provider((ref) => QuizRepository());

final quizDetailsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, quizId) async {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.fetchQuizDetails(quizId);
});
final subjectQuizzesProvider = FutureProvider.family<List<QuizModel>, int>((ref, subjectId) async {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.fetchSubjectQuizzes(subjectId);
});
