import 'package:edustream/core/services/api_service.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';

class QuizRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> fetchQuizDetails(int quizId) async {
    try {
      final response = await _apiService.get('quiz/$quizId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitQuiz(int quizId, Map<String, int> answers) async {
    try {
      final response = await _apiService.post('quiz/$quizId/submit', data: {
        'answers': answers,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<QuizModel>> fetchSubjectQuizzes(int subjectId) async {
    try {
      final response = await _apiService.get('content/subjects/$subjectId/quizzes');
      return (response.data as List)
          .map((json) => QuizModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
