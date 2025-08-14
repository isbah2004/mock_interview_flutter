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
import 'package:mock_interview/features/mcqinterviews/presentation/view/mcq_interview_view.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/args/mcq_interview_result_args.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/args/mcq_interview_args.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/mcq_interview_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_cubit.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/interview_setup_view.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/view/result_view.dart';

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
        final args = settings.arguments as InterviewResultArgs;
        return MaterialPageRoute(
          builder: (_) => ResultPage(evaluationResult: args.evaluationResult),
        );
      case AppRoutes.mcqInterviewSetup:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (_) => serviceLocator.get<McqInterviewBloc>(),
                child: const InterviewSetupPage(),
              ),
        );

      case AppRoutes.mcqInterview:
        final args = settings.arguments as McqInterviewArgs;
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => serviceLocator.get<McqInterviewBloc>(),
                  ),
                  BlocProvider(
                    create:
                        (_) => serviceLocator.get<TimerCubit>(
                          param1: 1800, // 30 minutes
                        ),
                  ),
                ],
                child: McqInterviewPage(
                  sessionId: args.sessionId,
                  questions: args.questions,
                ),
              ),
        );

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
