import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:mock_interview/features/ads/presentation/pages/ad_demo_page.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/cubit/timer_cubit.dart';
import 'package:mock_interview/firebase_options.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/cubits/theme_cubit/theme_cubit.dart';
import 'package:mock_interview/core/navigation/routes.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/theme/apptheme/light_theme.dart';
import 'package:mock_interview/core/theme/apptheme/dark_theme.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_bloc.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_event.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_bloc.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_bloc.dart';
import 'package:mock_interview/features/home/cubit/navigation_cubit.dart';
import 'package:mock_interview/features/ads/presentation/services/ad_integration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage first
  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In with the Web Client ID
  await GoogleSignIn.instance.initialize(
    serverClientId: AppSecrets.googleClientId,
  );

  await initializeDependencies();

  // Initialize ads after dependency injection
  try {
    final adService = serviceLocator<AdIntegrationService>();
    await adService.initialize();
  } catch (e) {
    // Ad initialization is non-critical, continue if it fails
    debugPrint('Ad initialization failed: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => serviceLocator<ThemeCubit>(),
        ),
        BlocProvider<AuthBloc>(
          create:
              (context) =>
                  serviceLocator<AuthBloc>()..add(AuthCheckRequested()),
        ),

        BlocProvider<UserCubit>(
          create: (context) {
            final userCubit = serviceLocator<UserCubit>();
            // Load user data from local storage after a small delay
            // to allow AuthBloc to complete its initial check
            Future.delayed(const Duration(milliseconds: 100), () {
              userCubit.loadUserFromLocalStorage();
            });
            return userCubit;
          },
        ),

        BlocProvider<TimerCubit>(
          create: (context) => serviceLocator<TimerCubit>(),
        ),
        BlocProvider<McqInterviewBloc>(
          create:
              (context) =>
                  serviceLocator<McqInterviewBloc>()
                    ..add(const StartJobTitleInput()),
        ),
        BlocProvider<VoiceInterviewBloc>(
          create: (context) => serviceLocator<VoiceInterviewBloc>(),
        ),
        BlocProvider<HomeBloc>(create: (context) => serviceLocator<HomeBloc>()),
        BlocProvider<NavigationCubit>(
          create: (context) => serviceLocator<NavigationCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mockee',
            theme: LightTheme.theme,
            // home: AdDemoPage(),
            darkTheme: DarkTheme.theme,
            themeMode: !themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // themeMode: ThemeMode.light,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
