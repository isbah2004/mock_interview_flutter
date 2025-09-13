import 'package:flutter/material.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/features/auth/presentation/view/forgot_password_view.dart';
import 'package:mock_interview/features/auth/presentation/view/login_view.dart';
import 'package:mock_interview/features/auth/presentation/view/reset_password.dart';
import 'package:mock_interview/features/auth/presentation/view/signup_view.dart';
import 'package:mock_interview/features/auth/presentation/view/splash_view.dart';
import 'package:mock_interview/features/home/presentation/view/home_view.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_setup_view.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/args/mcq_interview_result_args.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/args/mcq_interview_args.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_view.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_result_view.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/view/voice_interview_setup_view.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/view/interview_result_view.dart';
import 'package:mock_interview/features/voiceinterviews/data/models/voice_interview_evaluation_result.dart';
import 'package:mock_interview/core/models/voice_evaluation_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes - no animation changes for splash as requested
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      // All other routes use hero navigation with fade transition
      case AppRoutes.login:
        return _createHeroRoute(const LoginView(), heroTag: 'auth_login');
      case AppRoutes.register:
        return _createHeroRoute(const SignupView(), heroTag: 'auth_signup');

      case AppRoutes.forgotPassword:
        return _createHeroRoute(
          const ForgotPasswordView(),
          heroTag: 'auth_forgot',
        );
      case AppRoutes.resetPassword:
        return _createHeroRoute(
          const ResetPasswordView(),
          heroTag: 'auth_reset',
        );
      case AppRoutes.home:
        return _createHeroRoute(const HomeView(), heroTag: 'main_home');

      // Generic interview result route (keeps existing behavior)
      case AppRoutes.mcqInterviewResultView:
        final args = settings.arguments as InterviewResultArgs;
        return _createHeroRoute(
          McqResultView(evaluationResult: args.evaluationResult),
          heroTag: 'mcq_result',
        );

      // MCQ interview setup
      case AppRoutes.mcqInterviewSetupView:
        return _createHeroRoute(
          const McqInterviewSetupView(),
          heroTag: 'mcq_setup',
        );

      // MCQ interview
      case AppRoutes.mcqInterviewView:
        final args = settings.arguments as McqInterviewArgs;
        return _createHeroRoute(
          McqInterviewView(questions: args.questions, jobTitle: args.jobRole),
          heroTag: 'mcq_interview',
        );

      // Voice interview setup
      case AppRoutes.voiceInterviewSetupView:
        return _createHeroRoute(
          const VoiceInterviewSetupView(),
          heroTag: 'voice_setup',
        );

      // Voice interview
      case AppRoutes.voiceInterviewView:
        // This route should use direct navigation from setup screen, not named routes
        return _createHeroRoute(
          const Center(
            child: Text('Use VoiceInterviewSetupView to start interviews'),
          ),
          heroTag: 'voice_interview',
        );

      // Voice result view
      case AppRoutes.voiceResultView:
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;

          // Convert VoiceInterviewEvaluationResult to VoiceEvaluationModel if provided
          VoiceEvaluationModel? evaluation;
          if (args['evaluation'] != null) {
            final evalResult =
                args['evaluation'] as VoiceInterviewEvaluationResult;
            evaluation = VoiceEvaluationModel(
              evaluationId: '', // Generate empty ID since it's not stored yet
              sessionId: evalResult.sessionId,
              feedback: evalResult.feedback,
              communicationScore: evalResult.communicationScore,
              contentScore: evalResult.contentScore,
              overallScore: evalResult.overallScore,
              aiCorrectAnswers: evalResult.aiCorrectAnswers,
              totalQuestions: evalResult.totalQuestions,
              finalScore: evalResult.finalScore,
              percentage: evalResult.percentage,
              passed: evalResult.passed,
              sessionComplete: evalResult.sessionComplete,
              completedAt: evalResult.completedAt,
              conversationMessages:
                  [], // Empty for now, will be populated from session messages
            );
          }

          return _createHeroRoute(
            InterviewResultView(
              session: args['session'],
              config: args['config'],
              existingEvaluation: evaluation,
            ),
            heroTag: 'voice_result',
          );
        }
        return _createHeroRoute(
          const Scaffold(
            body: Center(
              child: Text('Voice result requires session and config arguments'),
            ),
          ),
          heroTag: 'voice_result_error',
        );

      // Test routes are handled elsewhere or the test screen was removed

      default:
        return _createHeroRoute(
          const Scaffold(body: Center(child: Text('No route defined'))),
          heroTag: 'error_route',
        );
    }
  }

  /// Create a route with hero transition and fade animation
  static PageRoute<T> _createHeroRoute<T>(
    Widget destination, {
    required String heroTag,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
