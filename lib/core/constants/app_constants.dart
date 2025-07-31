class AppConstants {
  // App Information
  static const String appName = 'Mock Interview';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_preference';
  static const String languageKey = 'language_preference';

  // Animation Durations
  static const int defaultAnimationDuration = 300;
  static const int splashScreenDuration = 2000;

  // Timeouts
  static const int networkTimeout = 30000; // 30 seconds
  static const int authTimeout = 60000; // 1 minute

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Interview Settings
  static const int defaultInterviewDuration = 30; // minutes
  static const int maxQuestionsPerInterview = 50;
  static const int minQuestionsPerInterview = 5;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxAudioSizeMB = 10;
  static const List<String> allowedImageExtensions = ['.jpg', '.jpeg', '.png'];
  static const List<String> allowedAudioExtensions = ['.mp3', '.wav', '.m4a'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}

class RouteConstants {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String interview = '/interview';
  static const String interviewDetail = '/interview-detail';
  static const String interviewSession = '/interview-session';
  static const String results = '/results';
  static const String settings = '/settings';
}

class DatabaseConstants {
  // User fields
  static const String userId = 'user_id';
  static const String userName = 'name';
  static const String userEmail = 'email';
  static const String userPhone = 'phone';
  static const String userPhotoUrl = 'photo_url';
  static const String userCreatedAt = 'created_at';
  static const String userUpdatedAt = 'updated_at';

  // Interview fields
  static const String interviewId = 'interview_id';
  static const String interviewTitle = 'title';
  static const String interviewDescription = 'description';
  static const String interviewCategory = 'category';
  static const String interviewDifficulty = 'difficulty';
  static const String interviewStatus = 'status';
  static const String interviewDuration = 'duration';
  static const String interviewCreatedAt = 'created_at';

  // Question fields
  static const String questionId = 'question_id';
  static const String questionText = 'question_text';
  static const String questionType = 'question_type';
  static const String questionOptions = 'options';
  static const String questionAnswer = 'expected_answer';
  static const String questionTimeLimit = 'time_limit';
}
