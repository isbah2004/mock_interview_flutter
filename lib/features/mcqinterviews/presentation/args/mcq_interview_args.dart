import 'package:equatable/equatable.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/question_model.dart';

class McqInterviewArgs extends Equatable {
  final String sessionId;
  final List<QuestionModel> questions;
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
