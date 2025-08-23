import 'package:fpdart/fpdart.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/usecases/usecase.dart';
import '../entities/interview_session.dart';
import '../entities/interview_config.dart';
import '../repositories/voice_interview_repository.dart';
import '../../data/models/voice_interview_evaluation_result.dart';

class EvaluateVoiceInterviewUseCase
    implements
        UseCase<VoiceInterviewEvaluationResult, EvaluateVoiceInterviewParams> {
  final VoiceInterviewRepository repository;

  EvaluateVoiceInterviewUseCase(this.repository);

  @override
  Future<Either<Failure, VoiceInterviewEvaluationResult>> call(
    EvaluateVoiceInterviewParams params,
  ) async {
    return await repository.evaluateVoiceInterview(
      session: params.session,
      config: params.config,
    );
  }
}

class EvaluateVoiceInterviewParams {
  final InterviewSession session;
  final InterviewConfig config;

  EvaluateVoiceInterviewParams({required this.session, required this.config});
}
