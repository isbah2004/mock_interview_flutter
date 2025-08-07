// lib/features/interview/data/models/interview_request_model.dart
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/core/extensions/enum_extensions.dart';

class InterviewRequestModel {
  final String userId;
  final String jobRole;
  final String interviewType;
  final DifficultyLevel difficultyLevel;
  final int numQuestions;
  final QuestionCategory category;
  final List<String>? answers;
  final String? questionId;

  const InterviewRequestModel({
    required this.userId,
    required this.jobRole,
    this.interviewType = 'mcq',
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
    this.answers,
    this.questionId,
  });

  factory InterviewRequestModel.fromJson(Map<String, dynamic> json) {
    return InterviewRequestModel(
      userId: json['user_id'] as String,
      jobRole: json['job_role'] as String,
      interviewType: json['interview_type'] as String,
      difficultyLevel: DifficultyLevelExtension.fromString(
        json['difficulty_level'] as String,
      ),
      numQuestions: json['num_questions'] as int,
      category: QuestionCategoryExtension.fromString(
        json['interview_type'] as String? ?? 'general',
      ),
      answers:
          json['answers'] != null ? List<String>.from(json['answers']) : null,
      questionId: json['question_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'job_role': jobRole,
      'interview_type': interviewType,
      'difficulty_level': difficultyLevel.name,
      'num_questions': numQuestions,
      'category': category.name,
      if (answers != null) 'answers': answers,
      if (questionId != null) 'question_id': questionId,
    };
  }
}
