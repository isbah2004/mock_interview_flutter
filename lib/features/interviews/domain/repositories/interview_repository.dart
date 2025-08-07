// import 'package:fpdart/fpdart.dart';
// import 'package:mock_interview/core/entities/session_stats.dart';
// import 'package:mock_interview/core/enums/difficulty_level.dart';
// import 'package:mock_interview/core/enums/interview_type.dart';
// import 'package:mock_interview/core/enums/question_category.dart';
// import 'package:mock_interview/core/errors/failures.dart';
// import 'package:mock_interview/core/entities/interview.dart';
// import 'package:mock_interview/core/entities/question.dart';


// abstract class InterviewRepository {
//   Future<Either<Failure, Question>> startMcqInterview({
//     required String userId,
//     required String jobRole,
//     required DifficultyLevel difficultyLevel,
//     required QuestionCategory category,
//     required int numQuestions,
//   });

//   Future<Either<Failure, Question>> submitMcqAnswer({
//     required String sessionId,
//     required String answer,
//     required String userId,
//     required String jobRole,
//   });

//   Stream<Either<Failure, Question>> startVoiceInterview({
//     required String userId,
//     required String jobRole,
//     required DifficultyLevel difficultyLevel,
//     required QuestionCategory category,
//     required InterviewType interviewType,
//   });

//   Future<Either<Failure, void>> submitVoiceAnswer({
//     required String sessionId,
//     required String answer,
//     required String userId,
//     required String jobRole,
//   });

//   Future<Either<Failure, void>> endVoiceInterview(String sessionId);

//   // Common Methods
//   Future<Either<Failure, SessionStats>> getSessionStats(String sessionId);
//   Future<Either<Failure, void>> deleteSession(String sessionId);

//   // Appwrite Integration
//   Future<Either<Failure, void>> saveSessionToAppwrite(InterviewSession session);
//   Future<Either<Failure, List<InterviewSession>>> getUserSessions(
//     String userId,
//   );
// }


import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/entities/evaluation_result.dart';
import 'package:mock_interview/core/entities/interview.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/core/errors/failures.dart';

abstract class InterviewRepository {
  Future<Either<Failure, Interview>> startInterview({
    required String userId,
    required String jobRole,
    required DifficultyLevel difficultyLevel,
    required int numQuestions,
    required QuestionCategory category,
  });

  Future<Either<Failure, EvaluationResult>> submitAnswers({
    required String sessionId,
    required String userId,
    required List<String> answers,
  });

  Future<Either<Failure, Map<String, dynamic>>> getSessionStats(String sessionId);
  Future<Either<Failure, void>> deleteSession(String sessionId);
  Future<Either<Failure, Map<String, dynamic>>> getActiveSessions();
  Future<Either<Failure, bool>> checkHealth();
}