import 'package:equatable/equatable.dart';

class QuestionResult extends Equatable {
  final int questionId;
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int score;
  final String explanation;

  const QuestionResult({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.score,
    required this.explanation,
  });

  @override
  List<Object> get props => [
        questionId,
        question,
        userAnswer,
        correctAnswer,
        isCorrect,
        score,
        explanation,
      ];
}