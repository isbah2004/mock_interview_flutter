import 'package:mock_interview/core/entities/interview.dart';
import 'package:mock_interview/core/extensions/enum_extensions.dart';
import 'question_model.dart';

class InterviewModel extends Interview {
  const InterviewModel({
    required super.sessionId,
    required super.jobRole,
    required super.difficulty,
    required super.category,
    required super.totalQuestions,
    required super.questions,
    required super.message,
    required super.sessionCreatedAt,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      sessionId: json['session_id'] as String,
      jobRole: json['job_role'] as String,
      difficulty: DifficultyLevelExtension.fromString(
        json['difficulty'] as String,
      ),
      category: QuestionCategoryExtension.fromString(
        json['category'] as String,
      ),
      totalQuestions: json['total_questions'] as int,
      questions:
          (json['questions'] as List)
              .map((q) => QuestionModel.fromJson(q))
              .toList(),
      message: json['message'] as String,
      sessionCreatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['session_created_at'] as num).toInt() * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'job_role': jobRole,
      'difficulty': difficulty.name,
      'category': category.name,
      'total_questions': totalQuestions,
      'questions': questions.map((q) => (q as QuestionModel).toJson()).toList(),
      'message': message,
      'session_created_at': sessionCreatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}
