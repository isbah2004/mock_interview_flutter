import 'package:mock_interview/core/services/gemini_ai_service/gemini_ai_service.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

class SendResponseUseCase {
  final GeminiAiService _aiService;

  SendResponseUseCase(this._aiService);

  Future<String> call(String userResponse) async {
    return await _aiService.sendVoiceMessage(userResponse);
  }

  Future<Map<String, dynamic>> evaluateInterview(
    InterviewSession session,
    InterviewConfig config,
  ) async {
    return await _aiService.evaluateVoiceInterview(session, config);
  }
}
