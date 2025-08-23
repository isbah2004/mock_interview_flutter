import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import '../entities/interview_session.dart';
import '../entities/interview_config.dart';
import '../../data/models/voice_interview_evaluation_result.dart';

abstract class VoiceInterviewRepository {
  Future<Either<Failure, VoiceInterviewEvaluationResult>>
  evaluateVoiceInterview({
    required InterviewSession session,
    required InterviewConfig config,
  });
}
