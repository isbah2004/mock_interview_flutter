import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String? questionId;
  final String questionText;
  final List<String>? options; // Only for MCQ
  final String? feedback;
  final double? score;
  final int? currentQuestionNumber;
  final int? totalQuestions;
  final String? userAnswer;
  final DateTime? answeredAt;

  const Question({
    this.questionId,
    required this.questionText,
    this.options,
    this.feedback,
    this.score,
    this.currentQuestionNumber,
    this.totalQuestions,
    this.userAnswer,
    this.answeredAt,
  });

  @override
  List<Object?> get props => [
    questionId,
    questionText,
    options,
    feedback,
    score,
    currentQuestionNumber,
    totalQuestions,
    userAnswer,
    answeredAt,
  ];

  Question copyWith({
    String? questionId,
    String? questionText,
    List<String>? options,
    String? feedback,
    double? score,
    int? currentQuestionNumber,
    int? totalQuestions,
    String? userAnswer,
    DateTime? answeredAt,
  }) {
    return Question(
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      feedback: feedback ?? this.feedback,
      score: score ?? this.score,
      currentQuestionNumber: currentQuestionNumber ?? this.currentQuestionNumber,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      userAnswer: userAnswer ?? this.userAnswer,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}