import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/features/mcqinterviews/data/models/interview_session_model.dart';
import 'package:mock_interview/core/errors/failures.dart';

abstract class InterviewRepository {
  Future<Either<Failure, InterviewSessionModel>> startInterview({
    required String userId,
    required String jobRole,
    required String difficultyLevel,
    required int numQuestions,
    required String category,
  });

  Future<Either<Failure, EvaluationResult>> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
    required String jobRole,
    required String difficultyLevel,
    required String category,
  });

  Future<Either<Failure, Map<String, dynamic>>> completeInterview({
    required String sessionId,
    required String userId,
    required int score,
    required int timeTaken,
    required int totalQuestions,
    required int correctAnswers,
  });
}
