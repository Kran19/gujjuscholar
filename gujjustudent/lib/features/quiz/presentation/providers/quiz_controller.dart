import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edustream/features/quiz/data/quiz_repository.dart';
import 'package:edustream/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:edustream/features/quiz/data/models/quiz_model.dart';

class QuizNotifier extends ChangeNotifier {
  final QuizRepository _repository;
  final int quizId;
  List<QuestionModel> questions = [];
  int currentQuestionIndex = 0;
  Map<String, int> answers = {};
  bool isLoading = false;
  bool isCompleted = false;
  bool isReviewMode = false;
  String? quizTitle;
  int? score;
  int? totalQuestions;
  String? error;

  // Timer fields
  Timer? _timer;
  int remainingSeconds = 0;

  QuizNotifier(this._repository, this.quizId) {
    fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _repository.fetchQuizDetails(quizId);
      quizTitle = data['title'] ?? 'Quiz';
      final List<dynamic> questionsJson = data['questions'] ?? [];
      questions = questionsJson.map((q) => QuestionModel.fromJson(q)).toList();
      
      // Initialize timer
      int durationMinutes = data['time_limit_minutes'] ?? 15;
      remainingSeconds = durationMinutes * 60;
      _startTimer();
      
      isLoading = false;
    } catch (e) {
      isLoading = false;
      error = e.toString();
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        submitQuiz(); // Auto-submit when time is up
      }
    });
  }

  String get formattedTime {
    final minutes = (remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void selectOption(int optionIndex) {
    final questionId = questions[currentQuestionIndex].id;
    answers[questionId] = optionIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<void> submitQuiz() async {
    if (isLoading || isCompleted) return;
    
    _timer?.cancel();
    isLoading = true;
    notifyListeners();
    try {
      // Ensure keys are strings for JSON compatibility
      final Map<String, int> stringKeyAnswers = {};
      answers.forEach((key, value) {
        stringKeyAnswers[key.toString()] = value;
      });

      final result = await _repository.submitQuiz(quizId, stringKeyAnswers);
      score = result['score'];
      totalQuestions = result['total'];
      isLoading = false;
      isCompleted = true;
    } catch (e) {
      isLoading = false;
      error = e.toString();
    }
    notifyListeners();
  }

  void toggleReviewMode() {
    isReviewMode = !isReviewMode;
    notifyListeners();
  }
}

final quizControllerProvider = ChangeNotifierProvider.autoDispose.family<QuizNotifier, int>((ref, quizId) {
  final repo = ref.watch(quizRepositoryProvider);
  return QuizNotifier(repo, quizId);
});
