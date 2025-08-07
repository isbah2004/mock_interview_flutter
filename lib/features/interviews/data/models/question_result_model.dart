import 'package:mock_interview/core/entities/question_result.dart';

class QuestionResultModel extends QuestionResult {
  const QuestionResultModel({
    required super.questionId,
    required super.question,
    required super.userAnswer,
    required super.correctAnswer,
    required super.isCorrect,
    required super.score,
    required super.explanation,
  });

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultModel(
      questionId: json['question_id'] as int,
      question: json['question'] as String,
      userAnswer: json['user_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      score: json['score'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question': question,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'score': score,
      'explanation': explanation,
    };
  }
}
