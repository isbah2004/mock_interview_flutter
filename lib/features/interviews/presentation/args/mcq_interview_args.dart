import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';

class McqInterviewArgs {
  final String jobRole;
  final DifficultyLevel difficulty;
  final QuestionCategory category;
  final int numberOfQuestions;
  final int timePerQuestion;

  McqInterviewArgs({
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.numberOfQuestions,
    required this.timePerQuestion,
  });
}


