import 'package:equatable/equatable.dart';
import 'package:mock_interview/core/models/mcq_question_model.dart';

class McqInterviewArgs extends Equatable {
  final String sessionId;
  final List<McqQuestionModel> questions;
  final String jobRole;
  final String difficultyLevel;
  final String category;

  const McqInterviewArgs({
    required this.questions,
    required this.sessionId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
  });

  @override
  List<Object?> get props => [
    sessionId,
    questions,
    jobRole,
    difficultyLevel,
    category,
  ];
}
