import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../core/entities/interview_session.dart';

/// Enhanced Navigation Service with enum-based routing
/// Provides type-safe navigation methods and centralized navigation logic
class NavigationService {
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  /// Global navigator key for accessing the navigator from anywhere in the app
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Get the current context from the navigator
  static BuildContext? get currentContext => _navigatorKey.currentContext;

  /// Get the current state from the navigator
  static NavigatorState? get navigator => _navigatorKey.currentState;

  // ==========================
  // Basic Navigation Methods
  // ==========================

  /// Navigate to a route using AppRoute enum
  static Future<T?> navigateTo<T extends Object?>(
    AppRoute route, {
    Object? arguments,
    bool clearStack = false,
  }) async {
    if (navigator == null) return null;

    if (clearStack) {
      return navigator!.pushNamedAndRemoveUntil(
        route.path,
        (route) => false,
        arguments: arguments,
      );
    } else {
      return navigator!.pushNamed(route.path, arguments: arguments);
    }
  }

  /// Replace current route with new route
  static Future<T?> replaceTo<T extends Object?, TO extends Object?>(
    AppRoute route, {
    Object? arguments,
    TO? result,
  }) async {
    if (navigator == null) return null;

    return navigator!.pushReplacementNamed(
      route.path,
      arguments: arguments,
      result: result,
    );
  }

  /// Go back to previous route
  static void goBack<T extends Object?>([T? result]) {
    if (navigator?.canPop() == true) {
      navigator!.pop(result);
    }
  }

  /// Pop until a specific route
  static void popUntil(AppRoute route) {
    if (navigator == null) return;

    navigator!.popUntil(ModalRoute.withName(route.path));
  }

  /// Clear navigation stack and navigate to route
  static Future<T?> clearAndNavigateTo<T extends Object?>(
    AppRoute route, {
    Object? arguments,
  }) {
    return navigateTo<T>(route, arguments: arguments, clearStack: true);
  }

  // ==========================
  // Authentication Navigation
  // ==========================

  /// Navigate to login screen
  static Future<void> navigateToLogin({bool clearStack = false}) {
    return navigateTo(AppRoute.login, clearStack: clearStack);
  }

  /// Navigate to signup screen
  static Future<void> navigateToSignup() {
    return navigateTo(AppRoute.signup);
  }

  /// Navigate to home after successful authentication
  static Future<void> navigateToHome({bool clearStack = true}) {
    return navigateTo(AppRoute.home, clearStack: clearStack);
  }

  /// Navigate to email verification
  static Future<void> navigateToEmailVerification({String? email}) {
    return navigateTo(AppRoute.emailVerification, arguments: {'email': email});
  }

  /// Navigate to reset password
  static Future<void> navigateToResetPassword() {
    return navigateTo(AppRoute.resetPassword);
  }

  // ==========================
  // Interview Navigation
  // ==========================

  /// Navigate to MCQ interview setup
  static Future<void> navigateToMCQInterviewSetup() {
    return navigateTo(AppRoute.mcqInterviewSetup);
  }

  /// Navigate to Voice interview setup
  static Future<void> navigateToVoiceInterviewSetup() {
    return navigateTo(AppRoute.voiceInterviewSetup);
  }

  /// Navigate to MCQ interview with configuration
  static Future<void> navigateToMCQInterview({
    String? jobRole,
    DifficultyLevel? difficulty,
    QuestionCategory? category,
    int numberOfQuestions = 10,
    Map<String, dynamic>? config,
  }) {
    final arguments =
        config ??
        {
          'jobRole': jobRole,
          'difficulty': difficulty,
          'category': category,
          'numberOfQuestions': numberOfQuestions,
        };

    return navigateTo(AppRoute.mcqInterview, arguments: arguments);
  }

  /// Navigate to Voice interview with configuration
  static Future<void> navigateToVoiceInterview({
    String? jobRole,
    DifficultyLevel? difficulty,
    QuestionCategory? category,
    Map<String, dynamic>? config,
  }) {
    final arguments =
        config ??
        {'jobRole': jobRole, 'difficulty': difficulty, 'category': category};

    return navigateTo(AppRoute.voiceInterview, arguments: arguments);
  }

  /// Navigate to interview results
  static Future<void> navigateToInterviewResults({
    String? sessionId,
    int? score,
    int? totalQuestions,
    int? correctAnswers,
    Duration? timeTaken,
    String? jobRole,
    DifficultyLevel? difficulty,
    Map<String, dynamic>? results,
    bool replaceCurrentRoute = true,
  }) {
    final arguments = {
      if (sessionId != null) 'sessionId': sessionId,
      if (score != null) 'score': score,
      if (totalQuestions != null) 'totalQuestions': totalQuestions,
      if (correctAnswers != null) 'correctAnswers': correctAnswers,
      if (timeTaken != null) 'timeTaken': timeTaken,
      if (jobRole != null) 'jobRole': jobRole,
      if (difficulty != null) 'difficulty': difficulty,
      if (results != null) 'results': results,
    };

    if (replaceCurrentRoute) {
      return replaceTo(AppRoute.interviewResults, arguments: arguments);
    } else {
      return navigateTo(AppRoute.interviewResults, arguments: arguments);
    }
  }

  // ==========================
  // Legacy Methods (for compatibility)
  // ==========================

  /// @deprecated Use navigateTo instead
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushNamed<T>(routeName, arguments: arguments) ??
        Future.value(null);
  }

  /// @deprecated Use replaceTo instead
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return navigator?.pushReplacementNamed<T, TO>(
          routeName,
          result: result,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  /// @deprecated Use clearAndNavigateTo instead
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigator?.pushNamedAndRemoveUntil<T>(
          newRouteName,
          predicate,
          arguments: arguments,
        ) ??
        Future.value(null);
  }

  /// @deprecated Use goBack instead
  static void pop<T extends Object?>([T? result]) {
    navigator?.pop<T>(result);
  }

  /// @deprecated Use popUntil with AppRoute instead
  static void popUntilNamed(String routeName) {
    navigator?.popUntil(ModalRoute.withName(routeName));
  }

  // Legacy convenience methods for backward compatibility
  static Future<void> goToHome() => navigateToHome();
  static Future<void> goToLogin() => navigateToLogin();
  static Future<void> goToSignup() => navigateToSignup();
  static Future<void> goToMcqInterviewSetup() => navigateToMCQInterviewSetup();
  static Future<void> goToVoiceInterviewSetup() =>
      navigateToVoiceInterviewSetup();
  static Future<void> goToMcqInterview({Map<String, dynamic>? config}) =>
      navigateToMCQInterview(config: config);
  static Future<void> goToVoiceInterview({Map<String, dynamic>? config}) =>
      navigateToVoiceInterview(config: config);
  static Future<void> goToInterviewResults({
    Map<String, dynamic>? results,
    bool replace = true,
  }) => navigateToInterviewResults(
    results: results,
    replaceCurrentRoute: replace,
  );

  // ==========================
  // Utility Methods
  // ==========================

  /// Check if navigator can pop
  static bool canPop() {
    return navigator?.canPop() ?? false;
  }

  /// Check if a route requires authentication
  static bool routeRequiresAuth(AppRoute route) {
    return route.requiresAuth;
  }

  /// Get current route name
  static String? getCurrentRouteName() {
    final context = currentContext;
    if (context == null) return null;

    return ModalRoute.of(context)?.settings.name;
  }

  /// Check if current route matches the given route
  static bool isCurrentRoute(AppRoute route) {
    return getCurrentRouteName() == route.path;
  }

  /// Handle navigation errors
  static void handleNavigationError(dynamic error, StackTrace stackTrace) {
    debugPrint('Navigation Error: $error');
    debugPrint('Stack Trace: $stackTrace');

    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle deep link navigation
  static Future<bool> handleDeepLink(String deepLink) async {
    try {
      final uri = Uri.parse(deepLink);
      final route = AppRouteExtensions.fromPath(uri.path);

      final arguments =
          uri.queryParameters.isNotEmpty ? uri.queryParameters : null;

      await navigateTo(route, arguments: arguments);
      return true;
    } catch (error, stackTrace) {
      handleNavigationError(error, stackTrace);
      return false;
    }
  }

  /// Generate deep link for a route
  static String generateDeepLink(
    AppRoute route, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri(path: route.path, queryParameters: queryParameters);

    return uri.toString();
  }

  // ==========================
  // UI Helper Methods
  // ==========================

  /// Show success snackbar
  static void showSuccessSnackBar(String message) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show error snackbar
  static void showErrorSnackBar(String message) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show info snackbar
  static void showInfoSnackBar(String message) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show custom dialog
  static Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    final context = currentContext;
    if (context == null) return Future.value(null);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => child,
    );
  }

  /// Show custom bottom sheet
  static Future<T?> showCustomBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    final context = currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      builder: (context) => child,
    );
  }
}
