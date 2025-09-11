class AppSecrets {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '680d2c3d00181a48c844';
  static const String databaseId = '687765bf0013ce99c541';

  static const String usersCollection = '68777f1300324ee21d1e';
  static const String interviewSessionsCollection = '68777f59001dc82cdeea';
  static const String mcqQuestionsCollection = '68777f4b0004adb16d79';
  static const String voiceMessagesCollection = '68a9c98c002b3aa3e610';
  static const String voiceEvaluationsCollection = '68a9cb450032d6a7696d';
  static const String mcqEvaluationsCollection = '68a9ca72000b6a61f781';
  static const String legacyCollection = '68a9cd840010767b4938';

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

  static const String profileImagesBucket = '68777f9e0022f5542b18';
  static const String audioRecordingsBucket = '68777fb30003a9092c43';

  static const String googleClientId =
      '371590192079-earn7itu6rd814ieh3015cu99715u1h4.apps.googleusercontent.com';
  static const String facebookAdsAppId = '1523117192438285';
  static const String interstitialAdPlacementId = 'IMG_16_9_APP_INSTALL#1523117192438285_1523117435771594'; // Facebook test placement ID

  static const String geminiApiKey = 'AIzaSyB4TN-4OUSgh2qBEfz0-fVznxHcO7iBPPM';
  // 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

  static const bool isProduction = false;
  static const String environment = isProduction ? 'production' : 'development';
}
