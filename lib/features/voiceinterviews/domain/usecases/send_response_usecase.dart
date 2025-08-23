import 'package:mock_interview/core/services/gemini_ai_service.dart';

class SendResponseUseCase {
  final AIService _aiService;

  SendResponseUseCase(this._aiService);

  Future<String> call(String userResponse) async {
    return await _aiService.sendMessage(userResponse);
  }
}
