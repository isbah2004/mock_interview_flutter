import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/navigation/routes.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/theme/apptheme/light_theme.dart';
import 'package:mock_interview/core/theme/apptheme/dark_theme.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_bloc.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
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
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
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
    
        BlocProvider<UserCubit>(create: (context)=> serviceLocator<UserCubit>()),
        BlocProvider<McqInterviewBloc>(
          create: (context) => serviceLocator<McqInterviewBloc>(),
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
