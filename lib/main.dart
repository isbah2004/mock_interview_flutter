import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_exports.dart';
import 'package:mock_interview/firebase_options.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/navigation/routes.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/theme/apptheme/light_theme.dart';
import 'package:mock_interview/core/theme/apptheme/dark_theme.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In with the Web Client ID
  await GoogleSignIn.instance.initialize(
    serverClientId: AppSecrets.googleClientId,
  );

  await initializeDependencies();
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
        BlocProvider<AuthBloc>(
          create:
              (context) =>
                  serviceLocator<AuthBloc>()..add(AuthCheckRequested()),
        ),

        BlocProvider<UserCubit>(
          create: (context) => serviceLocator<UserCubit>(),
        ),
        BlocProvider<InterviewBloc>(
          create: (context) => serviceLocator<InterviewBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mockee',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
