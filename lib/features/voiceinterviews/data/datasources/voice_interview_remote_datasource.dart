import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/services/gemini_ai_service.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/entities/interview_config.dart';
import '../models/voice_interview_evaluation_result.dart';

abstract class VoiceInterviewRemoteDataSource {
  Future<VoiceInterviewEvaluationResult> evaluateVoiceInterview(
    InterviewSession session,
    InterviewConfig config,
  );
}

class VoiceInterviewRemoteDataSourceImpl
    implements VoiceInterviewRemoteDataSource {
  final GeminiAIService _geminiAIService;

  VoiceInterviewRemoteDataSourceImpl({GeminiAIService? geminiAIService})
    : _geminiAIService = geminiAIService ?? GeminiAIService();

  @override
  Future<VoiceInterviewEvaluationResult> evaluateVoiceInterview(
    InterviewSession session,
    InterviewConfig config,
  ) async {
    try {
      // Use Gemini AI Service for evaluation
      final evaluationData = await _geminiAIService.evaluateInterview(
        session,
        config,
      );

      return VoiceInterviewEvaluationResult.fromJson(evaluationData);
    } catch (e) {
      throw ServerFailure('Failed to evaluate voice interview: $e');
    }
  }
}
