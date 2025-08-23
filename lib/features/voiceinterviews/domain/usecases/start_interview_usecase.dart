
import 'package:mock_interview/core/services/flutter_permission_service.dart';
import 'package:mock_interview/core/services/flutter_speech_service.dart';
import 'package:mock_interview/core/services/gemini_ai_service.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_config.dart';

class StartInterviewUseCase {
  final AIService _aiService;
  final SpeechService _speechService;
  final PermissionService _permissionService;

  StartInterviewUseCase(
    this._aiService,
    this._speechService,
    this._permissionService,
  );

  Future<String> call(InterviewConfig config) async {
    // Request permissions
    final micPermission =
        await _permissionService.requestMicrophonePermission();
    final speechPermission = await _permissionService.requestSpeechPermission();

    if (!micPermission || !speechPermission) {
      throw Exception('Required permissions not granted');
    }

    // Initialize services
    await _speechService.initialize();
    await _aiService.initialize(config);

    // Start interview
    return await _aiService.sendMessage(
      'Begin the mock interview for ${config.jobRole} with ${config.category.displayName.toLowerCase()} questions.',
    );
  }
}
