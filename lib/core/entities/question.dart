import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String? sessionId;
  final int questionNumber;
  final String questionText;
  final List<String>? options;
  final String correctAnswer;
  final String? userAnswer;
  final bool? isCorrect;
  final double? score;
  final String explanation;
  final String difficulty;
  final String category;
  final String topic;
  final String? jobRole;

  const Question({
    required this.id,
     this.sessionId,
    required this.questionNumber,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
    this.score,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.topic,
    required this.jobRole,
  });

  @override
  List<Object?> get props => [
    id,
    sessionId,
    questionNumber,
    questionText,
    options,
    correctAnswer,
    userAnswer,
    isCorrect,
    score,
    explanation,
    difficulty,
    category,
    topic,
    jobRole,
  ];

  Question copyWith({
    String? id,
    String? sessionId,
    int? questionNumber,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? userAnswer,
    bool? isCorrect,
    double? score,
    String? explanation,
    String? difficulty,
    String? category,
    String? topic,
    String? jobRole,
  }) {
    return Question(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      questionNumber: questionNumber ?? this.questionNumber,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      topic: topic ?? this.topic,
      jobRole: jobRole ?? this.jobRole,
    );
  }

  bool get isAnswered => userAnswer != null && userAnswer!.isNotEmpty;
  bool get isAnsweredCorrectly => isCorrect ?? false;
  double get questionScore => score ?? 0.0;
  
  Question answerQuestion(String answer) {
    return copyWith(
      userAnswer: answer,
      isCorrect: answer == correctAnswer,
      score: answer == correctAnswer ? 1.0 : 0.0,
    );
  }
}