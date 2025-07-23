import 'package:appwrite/appwrite.dart';
import 'package:dio/dio.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mock_interview/core/services/appwrite_service.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/core/services/websocket_service.dart';

// Auth
import 'package:mock_interview/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mock_interview/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mock_interview/features/auth/domain/repositories/auth_repository.dart';
import 'package:mock_interview/features/auth/domain/usecases/get_current_user.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_out.dart';
import 'package:mock_interview/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/update_profile.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';

// Splash
import 'package:mock_interview/features/splash/cubit/splash_cubit.dart';

// Home
import 'package:mock_interview/features/home/data/datasources/home_remote_data_source.dart';
import 'package:mock_interview/features/home/data/repositories/home_repository_impl.dart';
import 'package:mock_interview/features/home/domain/repositories/home_repository.dart';
import 'package:mock_interview/features/home/domain/usecases/get_user_stats.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_bloc.dart';

// Interview
import 'package:mock_interview/features/interview/data/datasources/interview_local_datasource.dart';
import 'package:mock_interview/features/interview/data/datasources/interview_remote_datasource.dart';
import 'package:mock_interview/features/interview/data/repositories/interview_repository_impl.dart';
import 'package:mock_interview/features/interview/domain/repositories/interview_repository.dart';
import 'package:mock_interview/features/interview/domain/usecases/start_mcq_interview.dart';
import 'package:mock_interview/features/interview/domain/usecases/start_voice_interview.dart';
import 'package:mock_interview/features/interview/domain/usecases/submit_mcq_answer.dart';
import 'package:mock_interview/features/interview/domain/usecases/submit_voice_answer.dart';
import 'package:mock_interview/features/interview/domain/usecases/end_voice_interview.dart';
import 'package:mock_interview/features/interview/domain/usecases/get_session_stats.dart';
import 'package:mock_interview/features/interview/domain/usecases/get_user_sessions.dart';
import 'package:mock_interview/features/interview/domain/usecases/delete_session.dart';
import 'package:mock_interview/features/interview/domain/usecases/save_session_to_appwrite.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // Appwrite instances (using static getters)
  serviceLocator.registerLazySingleton<Client>(() => AppwriteService.client);
  serviceLocator.registerLazySingleton<Account>(() => AppwriteService.account);
  serviceLocator.registerLazySingleton<Databases>(
    () => AppwriteService.databases,
  );
  serviceLocator.registerLazySingleton<Storage>(() => AppwriteService.storage);

  // External services
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton<WebSocketClient>(
    () => WebSocketClient(),
  );
  serviceLocator.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  serviceLocator.registerLazySingleton<FacebookAuth>(
    () => FacebookAuth.instance,
  );
  serviceLocator.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );
  serviceLocator.registerLazySingleton<NetworkService>(
    () => NetworkInfoImpl(serviceLocator<InternetConnection>()),
  );

  // Auth Data Sources
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      account: serviceLocator<Account>(),
      databases: serviceLocator<Databases>(),
      storage: serviceLocator<Storage>(),
      googleSignIn: serviceLocator<GoogleSignIn>(),
      facebookAuth: serviceLocator<FacebookAuth>(),
    ),
  );

  // Auth Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: serviceLocator<AuthRemoteDataSource>(),
      networkService: serviceLocator<NetworkService>(),
    ),
  );

  // Auth Use Cases
  serviceLocator.registerLazySingleton(
    () => SignInWithEmail(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SignUpWithEmail(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SignInWithGoogle(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SignInWithFacebook(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SignOut(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetCurrentUser(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SendPasswordResetEmail(serviceLocator<AuthRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => UpdateProfile(serviceLocator<AuthRepository>()),
  );

  // Auth Bloc
  serviceLocator.registerFactory(
    () => AuthBloc(
      signInWithEmail: serviceLocator<SignInWithEmail>(),
      signUpWithEmail: serviceLocator<SignUpWithEmail>(),
      signOut: serviceLocator<SignOut>(),
      getCurrentUser: serviceLocator<GetCurrentUser>(),
      sendPasswordResetEmail: serviceLocator<SendPasswordResetEmail>(),
    ),
  );

  // Interview Data Sources
  serviceLocator.registerLazySingleton<InterviewRemoteDataSource>(
    () => InterviewRemoteDataSourceImpl(
      dio: serviceLocator<Dio>(),
      webSocketClient: serviceLocator<WebSocketClient>(),
    ),
  );

  serviceLocator.registerLazySingleton<InterviewLocalDataSource>(
    () => InterviewLocalDataSourceImpl(databases: serviceLocator<Databases>()),
  );

  // Interview Repository
  serviceLocator.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(
      remoteDataSource: serviceLocator<InterviewRemoteDataSource>(),
      localDataSource: serviceLocator<InterviewLocalDataSource>(),
      networkService: serviceLocator<NetworkService>(),
    ),
  );

  // Interview Use Cases
  serviceLocator.registerLazySingleton(
    () => StartMcqInterviewUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => StartVoiceInterviewUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SubmitMcqAnswerUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SubmitVoiceAnswerUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => EndVoiceInterviewUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetSessionStatsUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetUserSessionsUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteSessionUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SaveSessionToAppwriteUseCase(serviceLocator<InterviewRepository>()),
  );

  // Splash Cubit
  serviceLocator.registerFactory(() => SplashCubit(serviceLocator<Account>()));

  // Home Data Sources
  serviceLocator.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(databases: serviceLocator<Databases>()),
  );

  // Home Repository
  serviceLocator.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: serviceLocator<HomeRemoteDataSource>(),
    ),
  );

  // Home Use Cases
  serviceLocator.registerLazySingleton(
    () => GetUserStats(serviceLocator<HomeRepository>()),
  );

  // Home Bloc
  serviceLocator.registerFactory(
    () => HomeBloc(getUserStats: serviceLocator<GetUserStats>()),
  );
}
