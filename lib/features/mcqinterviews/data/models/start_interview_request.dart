import 'package:equatable/equatable.dart';

class StartInterviewRequest extends Equatable {
  final String userId;
  final String jobRole;
  final String interviewType;
  final String difficultyLevel;
  final int numQuestions;
  final String category;

  const StartInterviewRequest({
    required this.userId,
    required this.jobRole,
    required this.interviewType,
    required this.difficultyLevel,
    required this.numQuestions,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'job_role': jobRole,
      'interview_type': interviewType,
      'difficulty_level': difficultyLevel,
      'num_questions': numQuestions,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
    userId,
    jobRole,
    interviewType,
    difficultyLevel,
    numQuestions,
    category,
  ];
}
