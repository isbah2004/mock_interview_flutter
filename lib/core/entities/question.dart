import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String questionText;
  final List<String>? options; // Only for MCQ
  final String? feedback;
  final double? score;
  final int? currentQuestionNumber;
  final int? totalQuestions;

  const Question({
    required this.questionText,
    this.options,
    this.feedback,
    this.score,
    this.currentQuestionNumber,
    this.totalQuestions,
  });

  @override
  List<Object?> get props => [
    questionText,
    options,
    feedback,
    score,
    currentQuestionNumber,
    totalQuestions,
  ];
}