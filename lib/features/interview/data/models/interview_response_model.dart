import 'package:mock_interview/core/entities/question.dart';

class InterviewResponseModel extends Question {
  final String? questionId;
  final bool? sessionComplete;
  final double? finalScore;

  const InterviewResponseModel({
    required super.questionText,
    super.options,
    super.feedback,
    super.score,
    super.currentQuestionNumber,
    super.totalQuestions,
    this.questionId,
    this.sessionComplete,
    this.finalScore,
  });

  factory InterviewResponseModel.fromJson(Map<String, dynamic> json) {
    return InterviewResponseModel(
      questionText: json['question'] ?? '',
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      feedback: json['feedback'],
      score: json['score']?.toDouble(),
      currentQuestionNumber: json['current_question_number'],
      totalQuestions: json['total_questions'],
      questionId: json['question_id'],
      sessionComplete: json['session_complete'],
      finalScore: json['final_score']?.toDouble(),
    );
  }

  Question toEntity() {
    return Question(
      questionText: questionText,
      options: options,
      feedback: feedback,
      score: score,
      currentQuestionNumber: currentQuestionNumber,
      totalQuestions: totalQuestions,
    );
  }
}
