class DatabaseConstants {
  // Database Configuration
  static const String databaseId = 'interview_app_db';

  // Collection IDs
  static const String usersCollection = 'users';
  static const String interviewSessionsCollection = 'interview_sessions';
  static const String mcqQuestionsCollection = 'mcq_questions';
  static const String voiceMessagesCollection = 'voice_messages';
  static const String voiceEvaluationsCollection = 'voice_evaluations';
  static const String mcqEvaluationsCollection = 'mcq_evaluations';

  // Interview Types
  static const String interviewTypeMCQ = 'mcq';
  static const String interviewTypeVoice = 'voice';

  // Message Types
  static const String messageTypeAI = 'ai';
  static const String messageTypeUser = 'user';
  static const String messageTypeSystem = 'system';

  // Difficulty Levels
  static const String difficultyBeginner = 'beginner';
  static const String difficultyIntermediate = 'intermediate';
  static const String difficultyAdvanced = 'advanced';

  // Categories
  static const String categoryGeneral = 'general';
  static const String categoryBehavioral = 'behavioral';
  static const String categoryTechnical = 'technical';
  static const String categoryIndustrySpecific = 'industrySpecific';
}
