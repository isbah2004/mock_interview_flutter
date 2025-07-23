// Route enums for type safety
enum AppRoute {
  // Authentication Routes
  splash('/', RouteCategory.auth),
  login('/login', RouteCategory.auth),
  signup('/signup', RouteCategory.auth),
  emailVerification('/email-verification', RouteCategory.auth),
  resetPassword('/reset-password', RouteCategory.auth),

  // Main App Routes
  home('/home', RouteCategory.main),
  profile('/profile', RouteCategory.main),
  settings('/settings', RouteCategory.main),


  mcqInterviewSetup('/mcq-interview-setup', RouteCategory.interview),
  mcqInterview('/mcq-interview', RouteCategory.interview),
  voiceInterviewSetup('/voice-interview-setup', RouteCategory.interview),
  voiceInterview('/voice-interview', RouteCategory.interview),
  interviewResults('/interview-results', RouteCategory.interview),


  // Legacy Routes (deprecated but kept for compatibility)
  aiMcqInterview('/ai-mcq-interview', RouteCategory.interview),
  aiInterviewResults('/ai-interview-results', RouteCategory.interview),
  results('/results', RouteCategory.interview),
  interview('/interview', RouteCategory.interview);

  const AppRoute(this.path, this.category);

  final String path;
  final RouteCategory category;

  @override
  String toString() => path;
}

// Route categories for better organization
enum RouteCategory { auth, main, interview, deprecated }

// Route argument types for type safety
enum RouteArgumentType { none, string, map, interviewConfig, userSession }

// Route configuration class
class RouteConfig {
  final AppRoute route;
  final RouteCategory category;
  final RouteArgumentType argumentType;
  final bool requiresAuth;
  final String title;
  final String? description;

  const RouteConfig({
    required this.route,
    required this.category,
    required this.argumentType,
    this.requiresAuth = false,
    required this.title,
    this.description,
  });
}

// Route definitions with metadata
class AppRoutes {
  static const Map<AppRoute, RouteConfig> _routes = {
    // Authentication Routes
    AppRoute.splash: RouteConfig(
      route: AppRoute.splash,
      category: RouteCategory.auth,
      argumentType: RouteArgumentType.none,
      requiresAuth: false,
      title: 'Splash Screen',
      description: 'App initialization and loading screen',
    ),
    AppRoute.login: RouteConfig(
      route: AppRoute.login,
      category: RouteCategory.auth,
      argumentType: RouteArgumentType.none,
      requiresAuth: false,
      title: 'Login',
      description: 'User login screen',
    ),
    AppRoute.signup: RouteConfig(
      route: AppRoute.signup,
      category: RouteCategory.auth,
      argumentType: RouteArgumentType.none,
      requiresAuth: false,
      title: 'Sign Up',
      description: 'User registration screen',
    ),
    AppRoute.emailVerification: RouteConfig(
      route: AppRoute.emailVerification,
      category: RouteCategory.auth,
      argumentType: RouteArgumentType.string,
      requiresAuth: false,
      title: 'Email Verification',
      description: 'Email verification screen',
    ),
    AppRoute.resetPassword: RouteConfig(
      route: AppRoute.resetPassword,
      category: RouteCategory.auth,
      argumentType: RouteArgumentType.string,
      requiresAuth: false,
      title: 'Reset Password',
      description: 'Password reset screen',
    ),

    // Main App Routes
    AppRoute.home: RouteConfig(
      route: AppRoute.home,
      category: RouteCategory.main,
      argumentType: RouteArgumentType.none,
      requiresAuth: true,
      title: 'Home',
      description: 'Main dashboard screen',
    ),
    AppRoute.profile: RouteConfig(
      route: AppRoute.profile,
      category: RouteCategory.main,
      argumentType: RouteArgumentType.string,
      requiresAuth: true,
      title: 'Profile',
      description: 'User profile management',
    ),
    AppRoute.settings: RouteConfig(
      route: AppRoute.settings,
      category: RouteCategory.main,
      argumentType: RouteArgumentType.none,
      requiresAuth: true,
      title: 'Settings',
      description: 'App settings and preferences',
    ),

   
    AppRoute.mcqInterviewSetup: RouteConfig(
      route: AppRoute.mcqInterviewSetup,
      category: RouteCategory.interview,
      argumentType: RouteArgumentType.none,
      requiresAuth: true,
      title: 'MCQ Interview Setup',
      description: 'Configure MCQ interview parameters',
    ),
    AppRoute.mcqInterview: RouteConfig(
      route: AppRoute.mcqInterview,
      category: RouteCategory.interview,
      argumentType: RouteArgumentType.interviewConfig,
      requiresAuth: true,
      title: 'MCQ Interview',
      description: 'Take MCQ interview',
    ),
    AppRoute.voiceInterviewSetup: RouteConfig(
      route: AppRoute.voiceInterviewSetup,
      category: RouteCategory.interview,
      argumentType: RouteArgumentType.none,
      requiresAuth: true,
      title: 'Voice Interview Setup',
      description: 'Configure voice interview parameters',
    ),
    AppRoute.voiceInterview: RouteConfig(
      route: AppRoute.voiceInterview,
      category: RouteCategory.interview,
      argumentType: RouteArgumentType.interviewConfig,
      requiresAuth: true,
      title: 'Voice Interview',
      description: 'Take voice interview',
    ),
    AppRoute.interviewResults: RouteConfig(
      route: AppRoute.interviewResults,
      category: RouteCategory.interview,
      argumentType: RouteArgumentType.userSession,
      requiresAuth: true,
      title: 'Interview Results',
      description: 'View interview results and statistics',
    ),
   

    // Deprecated Routes (kept for backward compatibility)
    AppRoute.aiMcqInterview: RouteConfig(
      route: AppRoute.aiMcqInterview,
      category: RouteCategory.deprecated,
      argumentType: RouteArgumentType.map,
      requiresAuth: true,
      title: 'AI MCQ Interview (Deprecated)',
      description: 'Legacy AI MCQ interview - use mcqInterview instead',
    ),
    AppRoute.aiInterviewResults: RouteConfig(
      route: AppRoute.aiInterviewResults,
      category: RouteCategory.deprecated,
      argumentType: RouteArgumentType.map,
      requiresAuth: true,
      title: 'AI Interview Results (Deprecated)',
      description: 'Legacy AI interview results - use interviewResults instead',
    ),
    AppRoute.results: RouteConfig(
      route: AppRoute.results,
      category: RouteCategory.deprecated,
      argumentType: RouteArgumentType.map,
      requiresAuth: true,
      title: 'Results (Deprecated)',
      description: 'Legacy results screen',
    ),
    AppRoute.interview: RouteConfig(
      route: AppRoute.interview,
      category: RouteCategory.deprecated,
      argumentType: RouteArgumentType.none,
      requiresAuth: true,
      title: 'Interview (Deprecated)',
      description: 'Legacy interview screen',
    ),
  };

  // Get route configuration
  static RouteConfig? getConfig(AppRoute route) => _routes[route];

  // Get all routes by category
  static List<AppRoute> getRoutesByCategory(RouteCategory category) {
    return _routes.entries
        .where((entry) => entry.value.category == category)
        .map((entry) => entry.key)
        .toList();
  }

  // Check if route requires authentication
  static bool requiresAuth(AppRoute route) {
    return _routes[route]?.requiresAuth ?? false;
  }

  // Get route title
  static String getTitle(AppRoute route) {
    return _routes[route]?.title ?? route.path;
  }

  // Get route description
  static String? getDescription(AppRoute route) {
    return _routes[route]?.description;
  }

  // Check if route is deprecated
  static bool isDeprecated(AppRoute route) {
    return _routes[route]?.category == RouteCategory.deprecated;
  }

  // Get argument type for route
  static RouteArgumentType getArgumentType(AppRoute route) {
    return _routes[route]?.argumentType ?? RouteArgumentType.none;
  }

  // Legacy constants for backward compatibility
  @Deprecated('Use AppRoute.splash instead')
  static String get splash => AppRoute.splash.path;

  @Deprecated('Use AppRoute.home instead')
  static String get home => AppRoute.home.path;

  @Deprecated('Use AppRoute.login instead')
  static String get login => AppRoute.login.path;

  @Deprecated('Use AppRoute.signup instead')
  static String get signup => AppRoute.signup.path;

  @Deprecated('Use AppRoute.profile instead')
  static String get profile => AppRoute.profile.path;

  @Deprecated('Use AppRoute.interview instead')
  static String get interview => AppRoute.interview.path;

  @Deprecated('Use AppRoute.aiMcqInterview instead')
  static String get aiMcqInterview => AppRoute.aiMcqInterview.path;

  @Deprecated('Use AppRoute.aiInterviewResults instead')
  static String get aiInterviewResults => AppRoute.aiInterviewResults.path;

  @Deprecated('Use AppRoute.results instead')
  static String get results => AppRoute.results.path;

  @Deprecated('Use AppRoute.emailVerification instead')
  static String get emailVerification => AppRoute.emailVerification.path;

  @Deprecated('Use AppRoute.resetPassword instead')
  static String get resetPassword => AppRoute.resetPassword.path;



  @Deprecated('Use AppRoute.mcqInterviewSetup instead')
  static String get mcqInterviewSetup => AppRoute.mcqInterviewSetup.path;

  @Deprecated('Use AppRoute.voiceInterviewSetup instead')
  static String get voiceInterviewSetup => AppRoute.voiceInterviewSetup.path;

  @Deprecated('Use AppRoute.voiceInterview instead')
  static String get voiceInterview => AppRoute.voiceInterview.path;



  @Deprecated('Use AppRoute.settings instead')
  static String get settings => AppRoute.settings.path;
}

// Extension methods for AppRoute
extension AppRouteExtensions on AppRoute {
  // Helper method to find route by path
  static AppRoute fromPath(String path) {
    for (AppRoute route in AppRoute.values) {
      if (route.path == path) {
        return route;
      }
    }
    return AppRoute.home; // Default fallback
  }

  // Get routes by category
  static List<AppRoute> getRoutesByCategory(RouteCategory category) {
    return AppRoute.values
        .where((route) => route.category == category)
        .toList();
  }

  // Check if route requires authentication
  bool get requiresAuth {
    switch (category) {
      case RouteCategory.auth:
        return false;
      case RouteCategory.main:
      case RouteCategory.interview:
      case RouteCategory.deprecated:
        return true;
    }
  }
}
