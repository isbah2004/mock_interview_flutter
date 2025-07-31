import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

class InterviewRequestModel {
  final String userId;
  final String jobRole;
  final String interviewType;
  final String difficultyLevel;
  final String category;
  final int? numQuestions;
  final String? answer;
  final String? questionId;

  InterviewRequestModel({
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficultyLevel,
    required this.category,
    this.numQuestions,
    this.answer,
    this.questionId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'job_role': jobRole,
      'interview_type': interviewType,
      'difficulty_level': difficultyLevel,
      'category': category,
    };

    if (numQuestions != null) json['num_questions'] = numQuestions;
    if (answer != null) json['answer'] = answer;
    if (questionId != null) json['question_id'] = questionId;

    return json;
  }

  factory InterviewRequestModel.fromMcqParams({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    required int numQuestions,
    String? answer,
    String? questionId,
  }) {
    return InterviewRequestModel(
      userId: userId,
      jobRole: jobRole,
      interviewType: 'mcq',
      difficultyLevel: difficultyLevel.name,
      category: category.name,
      numQuestions: numQuestions,
      answer: answer,
      questionId: questionId,
    );
  }

  factory InterviewRequestModel.fromVoiceParams({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    String? answer,
    String? questionId,
  }) {
    return InterviewRequestModel(
      userId: userId,
      jobRole: jobRole,
      interviewType: 'voice',
      difficultyLevel: difficultyLevel.name,
      category: category.name,
      answer: answer,
      questionId: questionId,
    );
  }
}
