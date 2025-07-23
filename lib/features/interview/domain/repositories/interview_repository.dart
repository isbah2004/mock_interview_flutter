import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/session_stats.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/entities/interview_session.dart';
import 'package:mock_interview/core/entities/question.dart';


abstract class InterviewRepository {
  // MCQ Methods
  Future<Either<Failure, Question>> startMcqInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
    required int numQuestions,
  });

  Future<Either<Failure, Question>> submitMcqAnswer({
    required String sessionId,
    required String answer,
    required String userId,
    required String jobRole,
  });

  // Voice Methods
  Stream<Either<Failure, Question>> startVoiceInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required QuestionCategory category,
  });

  Future<Either<Failure, void>> submitVoiceAnswer({
    required String sessionId,
    required String answer,
    required String userId,
    required String jobRole,
  });

  Future<Either<Failure, void>> endVoiceInterview(String sessionId);

  // Common Methods
  Future<Either<Failure, SessionStats>> getSessionStats(String sessionId);
  Future<Either<Failure, void>> deleteSession(String sessionId);

  // Appwrite Integration
  Future<Either<Failure, void>> saveSessionToAppwrite(InterviewSession session);
  Future<Either<Failure, List<InterviewSession>>> getUserSessions(
    String userId,
  );
}
