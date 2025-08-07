import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/services/api_service.dart';
import 'package:mock_interview/core/services/appwrite_service.dart';
import 'package:mock_interview/core/services/network_service.dart';
import 'package:mock_interview/features/auth/data/datasources/auth_local_data_source.dart';

// Auth
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
import 'package:mock_interview/features/interviews/domain/usecases/check_health.dart';
import 'package:mock_interview/features/interviews/domain/usecases/get_active_session.dart';
import 'package:mock_interview/features/interviews/domain/usecases/start_interview.dart';
import 'package:mock_interview/features/interviews/domain/usecases/submit_answers.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_bloc.dart';

// Home
import 'package:mock_interview/features/home/data/datasources/home_remote_data_source.dart';
import 'package:mock_interview/features/home/data/repositories/home_repository_impl.dart';
import 'package:mock_interview/features/home/domain/repositories/home_repository.dart';
import 'package:mock_interview/features/home/domain/usecases/get_user_stats.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_bloc.dart';

// Interview
import 'package:mock_interview/features/interviews/data/datasources/interview_remote_datasource.dart';
import 'package:mock_interview/features/interviews/data/repositories/interview_repository_impl.dart';
import 'package:mock_interview/features/interviews/domain/repositories/interview_repository.dart';
import 'package:mock_interview/features/interviews/domain/usecases/get_session_stats.dart';
import 'package:mock_interview/features/interviews/domain/usecases/delete_session.dart';
import 'package:mock_interview/features/interviews/presentation/cubit/mcq_counter_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // Firebase Auth instance
  serviceLocator.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  // Appwrite instances (using static getters)
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
  // External services
  serviceLocator.registerLazySingleton<ApiService>(() => ApiService());

  serviceLocator.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );
  serviceLocator.registerLazySingleton<NetworkService>(
    () => NetworkInfoImpl(serviceLocator<InternetConnection>()),
  );

  // Auth Data Sources
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
  // Auth Repository
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: serviceLocator<AuthRemoteDataSource>(),
      networkService: serviceLocator<NetworkService>(),
      localDataSource: serviceLocator<AuthLocalDataSource>(),
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

  // User Cubit
  serviceLocator.registerLazySingleton<UserCubit>(() => UserCubit());

  // Auth Bloc
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
    ),
  );

  // Interview Data Sources
  serviceLocator.registerLazySingleton<InterviewRemoteDataSource>(
    () =>
        InterviewRemoteDataSourceImpl(apiService: serviceLocator<ApiService>()),
  );

  // serviceLocator.registerLazySingleton<InterviewLocalDataSource>(
  //   () => InterviewLocalDataSourceImpl(
  //     databases: serviceLocator<appwrite.Databases>(),
  //   ),
  // );

  // Interview Repository
  serviceLocator.registerLazySingleton<InterviewRepository>(
    () => InterviewRepositoryImpl(
      remoteDataSource: serviceLocator<InterviewRemoteDataSource>(),
      // localDataSource: serviceLocator<InterviewLocalDataSource>(),
      networkService: serviceLocator<NetworkService>(),
    ),
  );

  // Interview Use Cases
  serviceLocator.registerLazySingleton(
    () => GetSessionStats(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteSession(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SubmitAnswers(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetActiveSessions(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => CheckHealth(serviceLocator<InterviewRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => StartInterview(serviceLocator<InterviewRepository>()),
  );
  // Home Data Sources
  serviceLocator.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      databases: serviceLocator<appwrite.Databases>(),
    ),
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
  serviceLocator.registerFactory(
    () => InterviewBloc(
      startInterviewUseCase: serviceLocator<StartInterview>(),
      submitAnswersUseCase: serviceLocator<SubmitAnswers>(),
    ),
  );
  serviceLocator.registerFactory(() => McqCounterCubit());
}
