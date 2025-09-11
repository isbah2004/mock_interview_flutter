import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/cubits/theme_cubit/theme_cubit.dart';
import 'package:mock_interview/core/services/appwrite_service.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/services/user_stats_service.dart';
import 'package:mock_interview/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mock_interview/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mock_interview/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mock_interview/features/auth/domain/repositories/auth_repository.dart';
import 'package:mock_interview/features/auth/domain/usecases/get_current_user.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_facebook.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/sign_out.dart';
import 'package:mock_interview/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:mock_interview/features/auth/domain/usecases/update_profile.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/domain/usecases/start_interview_usecase.dart';
import 'package:mock_interview/features/mcqinterviews/domain/usecases/submit_answers_usecase.dart';
import 'package:mock_interview/features/mcqinterviews/domain/usecases/complete_interview_usecase.dart';
import 'package:mock_interview/core/services/flutter_permission_service.dart';
import 'package:mock_interview/core/services/flutter_speech_service.dart';
import 'package:mock_interview/core/services/gemini_ai_service/gemini_ai_service.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/start_interview_usecase.dart'
    as voice_start;
import 'package:mock_interview/features/voiceinterviews/domain/usecases/send_response_usecase.dart';
import 'package:mock_interview/features/voiceinterviews/domain/usecases/handle_speech_usecase.dart';
import 'package:mock_interview/features/home/data/datasources/home_remote_data_source.dart';
import 'package:mock_interview/features/home/data/repositories/home_repository_impl.dart';
import 'package:mock_interview/features/home/domain/repositories/home_repository.dart';
import 'package:mock_interview/features/home/domain/usecases/get_user_stats.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/data/repositories/appwrite_mcq_interview_repository_impl.dart';
import 'package:mock_interview/features/mcqinterviews/domain/repositories/mcq_interview_repository.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_cubit.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_bloc.dart';
import 'package:mock_interview/features/home/cubit/navigation_cubit.dart';
import 'package:mock_interview/features/history/data/datasources/history_remote_data_source.dart';
import 'package:mock_interview/features/history/data/repositories/history_repository_impl.dart';
import 'package:mock_interview/features/history/domain/repositories/history_repository.dart';
import 'package:mock_interview/features/history/domain/usecases/get_history_usecase.dart';
import 'package:mock_interview/features/history/presentation/cubit/history_cubit.dart';
import 'package:mock_interview/features/ads/data/datasources/admob_datasource.dart';
import 'package:mock_interview/features/ads/data/repositories/ad_repository_impl.dart';
import 'package:mock_interview/features/ads/domain/repositories/ad_repository.dart';
import 'package:mock_interview/features/ads/domain/usecases/initialize_ads_usecase.dart';
import 'package:mock_interview/features/ads/domain/usecases/load_interstitial_ad_usecase.dart';
import 'package:mock_interview/features/ads/domain/usecases/show_interstitial_ad_usecase.dart';
import 'package:mock_interview/features/ads/presentation/services/ad_service.dart';
import 'package:mock_interview/features/ads/presentation/services/ad_integration_service.dart';
import 'package:mock_interview/features/ads/presentation/bloc/ad_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  serviceLocator.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  serviceLocator.registerLazySingleton<appwrite.Client>(
    () => AppwriteService.client,
  );
  serviceLocator.registerLazySingleton<appwrite.Account>(
    () => AppwriteService.account,
  );
  serviceLocator.registerLazySingleton<appwrite.Databases>(
    () => AppwriteService.databases,
  );
  serviceLocator.registerLazySingleton<appwrite.Storage>(
    () => AppwriteService.storage,
  );
  serviceLocator.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn.instance,
  );
  serviceLocator.registerLazySingleton<FacebookAuth>(
    () => FacebookAuth.instance,
  );
  serviceLocator.registerLazySingleton<GetStorage>(() => GetStorage());

  serviceLocator.registerLazySingleton<UnifiedDatabaseService>(
    () =>
        UnifiedDatabaseService(databases: serviceLocator<appwrite.Databases>()),
  );

  serviceLocator.registerLazySingleton<UserStatsService>(
    () => UserStatsService(
      databases: serviceLocator<appwrite.Databases>(),
      storage: serviceLocator<GetStorage>(),
    ),
  );

  serviceLocator.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );
  serviceLocator.registerLazySingleton<NetworkService>(
    () => NetworkInfoImpl(serviceLocator<InternetConnection>()),
  );

  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: serviceLocator<FirebaseAuth>(),
      databases: serviceLocator<appwrite.Databases>(),
      storage: serviceLocator<appwrite.Storage>(),
      googleSignIn: serviceLocator<GoogleSignIn>(),
      facebookAuth: serviceLocator<FacebookAuth>(),
    ),
  );

  serviceLocator.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(serviceLocator<GetStorage>()),
  );

  // Home Navigation Cubit
  serviceLocator.registerFactory<NavigationCubit>(() => NavigationCubit());
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: serviceLocator<AuthRemoteDataSource>(),
      networkService: serviceLocator<NetworkService>(),
      localDataSource: serviceLocator<AuthLocalDataSource>(),
    ),
  );

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

  serviceLocator.registerLazySingleton<UserCubit>(
    () => UserCubit(serviceLocator<UserStatsService>()),
  );

  serviceLocator.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  serviceLocator.registerFactory(
    () => AuthBloc(
      signInWithEmail: serviceLocator<SignInWithEmail>(),
      signUpWithEmail: serviceLocator<SignUpWithEmail>(),
      signOut: serviceLocator<SignOut>(),
      getCurrentUser: serviceLocator<GetCurrentUser>(),
      sendPasswordResetEmail: serviceLocator<SendPasswordResetEmail>(),
      signInWithGoogle: serviceLocator<SignInWithGoogle>(),
      signInWithFacebook: serviceLocator<SignInWithFacebook>(),
      userCubit: serviceLocator<UserCubit>(),
      userStatsService: serviceLocator<UserStatsService>(),
    ),
  );

  serviceLocator.registerLazySingleton<InterviewRepository>(
    () => AppwriteMcqInterviewRepositoryImpl(
      databaseService: serviceLocator<UnifiedDatabaseService>(),
      networkService: serviceLocator<NetworkService>(),
      aiService: serviceLocator<GeminiAiService>(),
    ),
  );

  serviceLocator.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      databases: serviceLocator<appwrite.Databases>(),
    ),
  );

  serviceLocator.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: serviceLocator<HomeRemoteDataSource>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetUserStats(serviceLocator<HomeRepository>()),
  );

  serviceLocator.registerFactory(
    () => HomeBloc(getUserStats: serviceLocator<GetUserStats>()),
  );

  serviceLocator.registerFactory(
    () => StartInterviewUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerFactory(
    () => SubmitAnswersUseCase(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerFactory(
    () => CompleteInterviewUseCase(serviceLocator<InterviewRepository>()),
  );

  serviceLocator.registerFactory(() => TimerCubit());

  // Unified MCQ Interview Bloc - produced by DI so views can obtain it via GetIt or
  // the Flutter BlocProvider created in main.dart.
  serviceLocator.registerFactory<McqInterviewBloc>(
    () => McqInterviewBloc(
      geminiAIService: serviceLocator<GeminiAiService>(),
      databaseService: serviceLocator<UnifiedDatabaseService>(),
      userStatsService: serviceLocator<UserStatsService>(),
      userCubit: serviceLocator<UserCubit>(),
    ),
  );

  // Ads feature: datasource, repository, usecases, service, and bloc
  serviceLocator.registerLazySingleton<AdRemoteDataSource>(
    () => AdMobDataSource(),
  );

  serviceLocator.registerLazySingleton<AdRepository>(
    () => AdRepositoryImpl(serviceLocator<AdRemoteDataSource>()),
  );

  serviceLocator.registerLazySingleton(
    () => InitializeAdsUseCase(serviceLocator<AdRepository>()),
  );

  serviceLocator.registerLazySingleton(
    () => LoadInterstitialAdUseCase(serviceLocator<AdRepository>()),
  );

  serviceLocator.registerLazySingleton(
    () => ShowInterstitialAdUseCase(serviceLocator<AdRepository>()),
  );

  // Ad presentation service and bloc
  serviceLocator.registerFactory<InterstitialAdBloc>(
    () => InterstitialAdBloc(
      initializeAdsUseCase: serviceLocator<InitializeAdsUseCase>(),
      loadInterstitialAdUseCase: serviceLocator<LoadInterstitialAdUseCase>(),
      showInterstitialAdUseCase: serviceLocator<ShowInterstitialAdUseCase>(),
    ),
  );

  serviceLocator.registerLazySingleton<AdService>(
    () => AdService(serviceLocator<InterstitialAdBloc>()),
  );

  serviceLocator.registerLazySingleton<AdIntegrationService>(
    () => AdIntegrationService(serviceLocator<InterstitialAdBloc>()),
  );

  // Unified Voice Interview Bloc
  serviceLocator.registerFactory<VoiceInterviewBloc>(
    () => VoiceInterviewBloc(
      databaseService: serviceLocator<UnifiedDatabaseService>(),
      networkService: serviceLocator<NetworkService>(),
      startInterviewUseCase:
          serviceLocator<voice_start.StartInterviewUseCase>(),
      sendResponseUseCase: serviceLocator<SendResponseUseCase>(),
      handleSpeechUseCase: serviceLocator<HandleSpeechUseCase>(),
      userCubit: serviceLocator<UserCubit>(),
      userStatsService: serviceLocator<UserStatsService>(),
    ),
  );

  serviceLocator.registerLazySingleton<PermissionService>(
    () => FlutterPermissionService(),
  );

  serviceLocator.registerLazySingleton<SpeechService>(
    () => FlutterSpeechService(),
  );

  final geminiInstance = GeminiAiService();
  serviceLocator.registerLazySingleton<GeminiAiService>(() => geminiInstance);

  serviceLocator.registerLazySingleton<voice_start.StartInterviewUseCase>(
    () => voice_start.StartInterviewUseCase(
      serviceLocator<GeminiAiService>(),
      serviceLocator<SpeechService>(),
      serviceLocator<PermissionService>(),
    ),
  );

  serviceLocator.registerLazySingleton<SendResponseUseCase>(
    () => SendResponseUseCase(serviceLocator<GeminiAiService>()),
  );

  serviceLocator.registerLazySingleton<HandleSpeechUseCase>(
    () => HandleSpeechUseCase(serviceLocator<SpeechService>()),
  );

  // History Feature
  serviceLocator.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(
      databaseService: serviceLocator<UnifiedDatabaseService>(),
    ),
  );

  serviceLocator.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      remoteDataSource: serviceLocator<HistoryRemoteDataSource>(),
    ),
  );

  serviceLocator.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(serviceLocator<HistoryRepository>()),
  );

  serviceLocator.registerFactory<HistoryCubit>(
    () => HistoryCubit(getHistoryUseCase: serviceLocator<GetHistoryUseCase>()),
  );
}
