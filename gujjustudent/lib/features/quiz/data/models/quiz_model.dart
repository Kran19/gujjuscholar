class QuizOptionModel {
  final int? id;
  final String optionText;
  final bool isCorrect;

  QuizOptionModel({
    this.id,
    required this.optionText,
    this.isCorrect = false,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id'],
      optionText: json['option_text'] ?? "",
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class QuestionModel {
  final String id;
  final String question;
  final List<QuizOptionModel> options;
  final int? marks;
  final String? imageUrl;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.marks,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    return QuestionModel(
      id: json['id'].toString(),
      question: json['question_text'] ?? json['question'] ?? "",
      options: optionsList.map((o) => QuizOptionModel.fromJson(o)).toList(),
      marks: json['marks'],
      imageUrl: json['image_url'],
    );
  }
}

enum QuizDifficulty { easy, medium, hard }

class QuizModel {
  final String id;
  final String title;
  final String? description;
  final String? standard;
  final String? subject;
  final int durationMinutes;
  final int totalQuestions;
  final int totalMarks;
  final String status;
  final QuizDifficulty difficulty;
  final int maxAttempts;
  final int usedAttempts;
  final bool isNew;
  final bool isFree;

  QuizModel({
    required this.id,
    required this.title,
    this.description,
    this.standard,
    this.subject,
    required this.durationMinutes,
    required this.totalQuestions,
    this.totalMarks = 0,
    required this.status,
    this.difficulty = QuizDifficulty.medium,
    this.maxAttempts = 3,
    this.usedAttempts = 0,
    this.isNew = false,
    this.isFree = false,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'] ?? "",
      description: json['description'],
      standard: json['standard_name'],
      subject: json['subject_name'],
      durationMinutes: json['time_limit_minutes'] ?? 15,
      totalQuestions: json['questions_count'] ?? json['total_questions'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      status: json['status'] ?? "active",
      difficulty: _parseDifficulty(json['difficulty']),
      maxAttempts: json['max_attempts'] ?? 3,
      usedAttempts: json['used_attempts'] ?? 0,
      isNew: json['is_new'] ?? false,
      isFree: json['is_free'] ?? false,
    );
  }

  static QuizDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty == null) return QuizDifficulty.medium;
    final value = difficulty.toString().toLowerCase();
    if (value.contains('easy')) return QuizDifficulty.easy;
    if (value.contains('hard')) return QuizDifficulty.hard;
    return QuizDifficulty.medium;
  }

  bool get retakeAvailable => usedAttempts < maxAttempts;
  String get durationString => "$durationMinutes min";

  static List<QuizModel> get dummyQuizzes {
    return [
      // Standard 10 - Maths
      QuizModel(
        id: "1",
        title: "Algebra Basics Quiz",
        standard: "Standard 10",
        subject: "Mathematics",
        durationMinutes: 15,
        totalQuestions: 10,
        status: "active",
        difficulty: QuizDifficulty.easy,
        isNew: true,
        isFree: true,
      ),
      QuizModel(
        id: "2",
        title: "Quadratic Equations",
        standard: "Standard 10",
        subject: "Mathematics",
        durationMinutes: 20,
        totalQuestions: 15,
        status: "active",
        difficulty: QuizDifficulty.medium,
        usedAttempts: 1,
      ),
      QuizModel(
        id: "3",
        title: "Maths Full Syllabus Test",
        standard: "Standard 10",
        subject: "Mathematics",
        durationMinutes: 45,
        totalQuestions: 40,
        status: "active",
        difficulty: QuizDifficulty.hard,
      ),
      // Standard 10 - Science
      QuizModel(
        id: "4",
        title: "Chemical Reactions",
        standard: "Standard 10",
        subject: "Science",
        durationMinutes: 15,
        totalQuestions: 10,
        status: "active",
        difficulty: QuizDifficulty.medium,
        isFree: true,
      ),
      QuizModel(
        id: "5",
        title: "Life Processes",
        standard: "Standard 10",
        subject: "Science",
        durationMinutes: 20,
        totalQuestions: 12,
        status: "active",
        difficulty: QuizDifficulty.medium,
      ),
      // Standard 9
      QuizModel(
        id: "6",
        title: "Ancient History Quiz",
        standard: "Standard 9",
        subject: "History",
        durationMinutes: 15,
        totalQuestions: 10,
        status: "active",
        difficulty: QuizDifficulty.easy,
        isFree: true,
      ),
       QuizModel(
        id: "7",
        title: "Motion & Force",
        standard: "Standard 9",
        subject: "Physics",
        durationMinutes: 25,
        totalQuestions: 20,
        status: "active",
        difficulty: QuizDifficulty.medium,
        isFree: true,
      ),
    ];
  }
}
