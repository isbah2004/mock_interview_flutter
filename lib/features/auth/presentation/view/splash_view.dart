import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/utils/constants/images.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_event.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_state.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/onboarding/presentation/cubit/onboarding_cubit.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Initialize native splash removal and animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Remove the native splash screen after a short delay to show smooth transition
      Future.delayed(const Duration(milliseconds: 500), () {
        FlutterNativeSplash.remove();
      });

      // Start animations
      _backgroundController.forward();
      _logoController.forward();

      // Trigger auth check after animations begin
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          context.read<AuthBloc>().add(AuthCheckRequested());
        }
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          // Check onboarding status before navigating to login
          final onboardingCubit = context.read<OnboardingCubit>();
          if (onboardingCubit.hasSeenOnboarding()) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPurple.withOpacityCompat(0.15),
                      theme.colorScheme.surface,
                      AppColors.primaryPurple.withOpacityCompat(0.08),
                      theme.colorScheme.surface,
                    ],
                    stops: [
                      0.0,
                      0.3 + (_backgroundAnimation.value * 0.2),
                      0.7 + (_backgroundAnimation.value * 0.2),
                      1.0,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated background particles
                    ...List.generate(6, (index) {
                      return AnimatedBuilder(
                        animation: _backgroundAnimation,
                        builder: (context, child) {
                          final size = 40.0 + (index * 15.0);
                          return Positioned(
                            top:
                                100 +
                                (index * 120.0) +
                                (_backgroundAnimation.value * 50),
                            left:
                                (index % 2 == 0)
                                    ? -30 + (_backgroundAnimation.value * 60)
                                    : MediaQuery.of(context).size.width -
                                        size +
                                        20 -
                                        (_backgroundAnimation.value * 60),
                            child: Opacity(
                              opacity: 0.1 * _backgroundAnimation.value,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primaryPurple.withOpacityCompat(
                                        0.3,
                                      ),
                                      AppColors.primaryPurple.withOpacityCompat(
                                        0.1,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Logo with enhanced glow effect
                          AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScaleAnimation.value.clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Opacity(
                                  opacity: _logoOpacityAnimation.value.clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.surface
                                              .withOpacityCompat(0.9),
                                          theme.colorScheme.surface
                                              .withOpacityCompat(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: AppColors.primaryPurple
                                            .withOpacityCompat(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple
                                              .withOpacityCompat(0.3),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacityCompat(
                                            0.1,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(-5, -5),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      AppImages.logo,
                                      height: 120,
                                      width: 120,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 48),

                          // App Name with enhanced styling
                          AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _logoOpacityAnimation.value.clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: ShaderMask(
                                  shaderCallback:
                                      (bounds) => LinearGradient(
                                        colors: [
                                          AppColors.primaryPurple,
                                          AppColors.primaryPurpleDark,
                                        ],
                                      ).createShader(bounds),
                                  child: Text(
                                    'InterviewAce',
                                    style: theme.textTheme.headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                          fontSize: 32,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Enhanced tagline
                          AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: (_logoOpacityAnimation.value * 0.9)
                                    .clamp(0.0, 1.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryPurple
                                            .withOpacityCompat(0.1),
                                        AppColors.primaryPurple
                                            .withOpacityCompat(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primaryPurple
                                          .withOpacityCompat(0.2),
                                    ),
                                  ),
                                  child: Text(
                                    'Prepare • Practice • Succeed',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: AppColors.primaryPurple,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 80),

                          // Enhanced loading indicator
                          if (state is AuthLoading)
                            AnimatedBuilder(
                              animation: _backgroundAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      0.8 + (_backgroundAnimation.value * 0.2),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.surface
                                              .withOpacityCompat(0.9),
                                          theme.colorScheme.surface
                                              .withOpacityCompat(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primaryPurple
                                            .withOpacityCompat(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryPurple
                                              .withOpacityCompat(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryPurple,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
