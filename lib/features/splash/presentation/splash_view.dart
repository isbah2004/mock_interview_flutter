import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/navigation/navigation_service.dart';
import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/core/di/service_locator.dart';
import 'package:mock_interview/features/splash/cubit/splash_cubit.dart';
import 'package:mock_interview/features/splash/cubit/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<SplashCubit>();

        // Add a delay to show splash screen and then check auth
        Future.delayed(const Duration(seconds: 2), () {
          cubit.checkAuthStatus();
        });

        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is SplashAuthenticated) {
              NavigationService.goToHome();
            } else if (state is SplashUnauthenticated) {
              NavigationService.goToLogin();
            }
          },
          child: BlocBuilder<SplashCubit, SplashState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.logo, height: 200),
                    const SizedBox(height: 40),
                    if (state is SplashLoading)
                      const CircularProgressIndicator(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
