class AppSecrets {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = 'YOUR_APPWRITE_PROJECT_ID';
  static const String databaseId = 'YOUR_APPWRITE_DATABASE_ID';

  static const String usersCollection = 'YOUR_USERS_COLLECTION_ID';
  static const String interviewSessionsCollection = 'YOUR_INTERVIEW_SESSIONS_COLLECTION_ID';
  static const String mcqQuestionsCollection = 'YOUR_MCQ_QUESTIONS_COLLECTION_ID';
  static const String voiceMessagesCollection = 'YOUR_VOICE_MESSAGES_COLLECTION_ID';
  static const String voiceEvaluationsCollection = 'YOUR_VOICE_EVALUATIONS_COLLECTION_ID';
  static const String mcqEvaluationsCollection = 'YOUR_MCQ_EVALUATIONS_COLLECTION_ID';
  static const String legacyCollection = 'YOUR_LEGACY_COLLECTION_ID';

  static const String interviewTypeMCQ = 'mcq';
  static const String interviewTypeVoice = 'voice';

  static const String messageTypeAI = 'ai';
  static const String messageTypeUser = 'user';
  static const String messageTypeSystem = 'system';

  static const String difficultyBeginner = 'easy';
  static const String difficultyIntermediate = 'medium';
  static const String difficultyAdvanced = 'hard';

  static const String categoryGeneral = 'general';
  static const String categoryBehavioral = 'behavioral';
  static const String categoryTechnical = 'technical';
  static const String categoryIndustrySpecific = 'industrySpecific';

  static const String profileImagesBucket = 'YOUR_PROFILE_IMAGES_BUCKET_ID';
  static const String audioRecordingsBucket = 'YOUR_AUDIO_RECORDINGS_BUCKET_ID';

  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String facebookAdsAppId = 'YOUR_FACEBOOK_ADS_APP_ID';
  static const String interstitialAdPlacementId = 'YOUR_INTERSTITIAL_AD_PLACEMENT_ID';

  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  static const bool isProduction = false;
  static const String environment = isProduction ? 'production' : 'development';
}
