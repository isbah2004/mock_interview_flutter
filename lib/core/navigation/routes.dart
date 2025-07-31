import 'package:flutter/material.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/features/auth/presentation/view/email_verification_view.dart';
import 'package:mock_interview/features/auth/presentation/view/forgot_password_view.dart';
import 'package:mock_interview/features/auth/presentation/view/login_view.dart';
import 'package:mock_interview/features/auth/presentation/view/reset_password.dart';
import 'package:mock_interview/features/auth/presentation/view/signup_view.dart';
import 'package:mock_interview/features/auth/presentation/view/splash_view.dart';
import 'package:mock_interview/features/home/presentation/view/home_view.dart';
import 'package:mock_interview/features/interviews/presentation/args/mcq_interview_args.dart';
import 'package:mock_interview/features/interviews/presentation/view/interview_result_view.dart';
import 'package:mock_interview/features/interviews/presentation/view/mcq_interview_setup_view.dart';
import 'package:mock_interview/features/interviews/presentation/view/mcq_interview_view.dart';
import 'package:mock_interview/features/interviews/presentation/view/voice_interview_setup_view.dart';
import 'package:mock_interview/features/interviews/presentation/view/voice_interview_view.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const SignupView());
      case AppRoutes.emailVerification:
        return MaterialPageRoute(builder: (_) => const EmailVerificationView());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordView());
      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordView());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case AppRoutes.interviewResultView:
        return MaterialPageRoute(
          builder: (_) => const InterviewResultsScreen(),
        );
      case AppRoutes.mcqInterviewSetup:
        return MaterialPageRoute(
          builder: (_) => const MCQInterviewSetupScreen(),
        );
      case AppRoutes.voiceInterviewSetup:
        return MaterialPageRoute(
          builder: (_) => const VoiceInterviewSetupScreen(),
        );
      case AppRoutes.mcqInterview:
        final args = settings.arguments as McqInterviewArgs;
        return MaterialPageRoute(
          builder:
              (_) => MCQInterviewScreen(
                jobRole: args.jobRole,
                difficulty: args.difficulty,
                category: args.category,
                numberOfQuestions: args.numberOfQuestions,
                timePerQuestion: args.timePerQuestion,
              ),
        );
      case AppRoutes.voiceInterview:
        return MaterialPageRoute(builder: (_) => const VoiceInterviewScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
