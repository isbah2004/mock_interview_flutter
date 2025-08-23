import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/features/auth/presentation/view/email_verification_view.dart';
import 'package:mock_interview/features/auth/presentation/view/forgot_password_view.dart';
import 'package:mock_interview/features/auth/presentation/view/login_view.dart';
import 'package:mock_interview/features/auth/presentation/view/reset_password.dart';
import 'package:mock_interview/features/auth/presentation/view/signup_view.dart';
import 'package:mock_interview/features/auth/presentation/view/splash_view.dart';
import 'package:mock_interview/features/home/presentation/view/home_view.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_setup_view_new.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/args/mcq_interview_result_args.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/args/mcq_interview_args.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq/mcq_interview_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_cubit.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_view_new.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_result_view.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/view/voice_interview_setup_view.dart';

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

      // Generic interview result route (keeps existing behavior)
      case AppRoutes.mcqInterviewResultView:
        final args = settings.arguments as InterviewResultArgs;
        return MaterialPageRoute(
          builder:
              (_) => McqResultView(evaluationResult: args.evaluationResult),
        );

      // MCQ interview setup
      case AppRoutes.mcqInterviewSetupView:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => serviceLocator.get<McqInterviewBloc>(),
                child: const McqInterviewSetupView(),
              ),
        );

      // MCQ interview
      case AppRoutes.mcqInterviewView:
        final args = settings.arguments as McqInterviewArgs;
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => serviceLocator.get<McqInterviewBloc>(),
                  ),
                  BlocProvider(
                    // TimerCubit is now registered as a simple factory (no constructor params)
                    create: (_) => serviceLocator.get<TimerCubit>(),
                  ),
                ],
                child: McqInterviewView(
                  sessionId: args.sessionId,
                  questions: args.questions, userId: '', jobRole: '', difficultyLevel: '', category: '',
                ),
              ),
        );

      // Voice interview setup
      case AppRoutes.voiceInterviewSetupView:
        return MaterialPageRoute(
          builder: (_) => const VoiceInterviewSetupView(),
        );

      // Voice interview
      case AppRoutes.voiceInterviewView:
        // This route should use direct navigation from setup screen, not named routes
        return MaterialPageRoute(
          builder:
              (_) => Container(
                child: const Center(
                  child: Text(
                    'Use VoiceInterviewSetupView to start interviews',
                  ),
                ),
              ),
        );

      // Voice result view
      // case AppRoutes.voiceResultView:
      //   return MaterialPageRoute(
      //     builder: (_) => const InterviewResultView(),
      //   );

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
