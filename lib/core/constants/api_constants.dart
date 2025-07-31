class ApiConstants {
  static const String baseUrl = 'https://testagent-production-8771.up.railway.app';
  static const String wsBaseUrl = 'ws://your-api-domain.com';

  // MCQ Endpoints
  static const String startInterview = '/api/v1/start_interview';
  static const String submitResponse = '/api/v1/submit_response';
  static const String sessionStats = '/api/v1/session_stats';
  static const String deleteSession = '/api/v1/session';

  // WebSocket Endpoints
  static const String voiceInterview = '/ws/voice_interview';


}
