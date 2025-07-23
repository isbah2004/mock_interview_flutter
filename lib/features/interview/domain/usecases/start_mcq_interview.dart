import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../../../../core/entities/question.dart';
import '../../../../core/entities/interview_session.dart';
import '../repositories/interview_repository.dart';

class StartMcqInterviewUseCase {
  final InterviewRepository repository;

  StartMcqInterviewUseCase(this.repository);

  Future<Either<Failure, Question>> call(StartMcqInterviewParams params) async {
    return await repository.startMcqInterview(
      userId: params.userId,
      jobRole: params.jobRole,
      difficultyLevel: params.difficultyLevel,
      category: params.category,
      numQuestions: params.numQuestions,
    );
  }
}

class StartMcqInterviewParams {
  final String userId;
  final String jobRole;
  final DifficultyLevel difficultyLevel;
  final QuestionCategory category;
  final int numQuestions;

  StartMcqInterviewParams({
    required this.userId,
    required this.jobRole,
    required this.difficultyLevel,
    required this.category,
    required this.numQuestions,
  });
}
