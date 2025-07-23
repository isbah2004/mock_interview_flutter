import 'package:flutter/material.dart';
import 'package:mock_interview/features/interview/presentation/view/interview_result_view.dart';
import 'package:mock_interview/features/interview/presentation/view/mcq_interview_setup_view.dart';
import 'package:mock_interview/features/interview/presentation/view/mcq_interview_view.dart';
import 'package:mock_interview/features/interview/presentation/view/voice_interview_setup_view.dart';
import 'package:mock_interview/features/interview/presentation/view/voice_interview_view.dart';
import 'app_routes.dart';

// Import actual screens
import '../../features/splash/presentation/splash_view.dart';
import '../../features/home/presentation/view/home_view.dart';
import '../../features/auth/presentation/view/login_view.dart';
import '../../features/auth/presentation/view/signup_view.dart';
import '../../features/auth/presentation/view/email_verification_view.dart';
import '../../features/auth/presentation/view/reset_password.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final appRoute = AppRouteExtensions.fromPath(settings.name ?? '/');

    switch (appRoute) {
      case AppRoute.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case AppRoute.home:
        return MaterialPageRoute(builder: (_) => const HomeView());

      case AppRoute.login:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case AppRoute.signup:
        return MaterialPageRoute(builder: (_) => const SignupView());

      case AppRoute.emailVerification:
        return MaterialPageRoute(builder: (_) => const EmailVerificationView());

      case AppRoute.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordView());

      case AppRoute.mcqInterviewSetup:
        return MaterialPageRoute(
          builder: (_) => const MCQInterviewSetupScreen(),
        );

      case AppRoute.voiceInterviewSetup:
        return MaterialPageRoute(
          builder: (_) => const VoiceInterviewSetupScreen(),
        );

      case AppRoute.mcqInterview:
        return MaterialPageRoute(builder: (_) => const MCQInterviewScreen());

      case AppRoute.voiceInterview:
        return MaterialPageRoute(builder: (_) => const VoiceInterviewScreen());

      case AppRoute.interviewResults:
        return MaterialPageRoute(
          builder: (_) => const InterviewResultsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: const Center(
                  child: Text(
                    '404 - Page Not Found',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
        );
    }
  }
}

// Placeholder screens for missing screens
class AppProfileScreen extends StatelessWidget {
  final String username;

  const AppProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile - $username')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}

class AIInterviewResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final List<dynamic> results;
  final String jobRole;

  const AIInterviewResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.results,
    required this.jobRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Job Role: $jobRole'),
            Text('Score: $score/$totalQuestions'),
            Text('Correct Answers: $correctAnswers'),
          ],
        ),
      ),
    );
  }
}

class InterviewHistoryScreen extends StatelessWidget {
  const InterviewHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview History')),
      body: const Center(child: Text('Interview History Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen')),
    );
  }
}
