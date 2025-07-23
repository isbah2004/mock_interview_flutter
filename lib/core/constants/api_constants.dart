class ApiConstants {
  static const String baseUrl = 'http://your-api-domain.com';
  static const String wsBaseUrl = 'ws://your-api-domain.com';

  // MCQ Endpoints
  static const String startInterview = '/api/v1/interview/start_interview';
  static const String submitResponse = '/api/v1/interview/submit_response';
  static const String sessionStats = '/api/v1/interview/session_stats';
  static const String deleteSession = '/api/v1/interview/session';

  // WebSocket Endpoints
  static const String voiceInterview = '/ws/voice_interview';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
