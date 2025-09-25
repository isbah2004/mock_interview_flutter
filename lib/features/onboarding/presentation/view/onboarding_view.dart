import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:mock_interview/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:mock_interview/features/onboarding/presentation/widgets/onboarding_indicator.dart';
import 'package:mock_interview/features/onboarding/data/onboarding_data.dart';
import 'package:mock_interview/core/navigation/routes_name.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<dynamic> _onboardingPages;
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late AnimationController _headerController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingPages = OnboardingData.getOnboardingPages();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingCubit>().startOnboarding(_onboardingPages.length);
      _headerController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipOnboarding() {
    context.read<OnboardingCubit>().skipOnboarding();
  }

  void _completeOnboarding() {
    context.read<OnboardingCubit>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingFinished) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      transform: GradientRotation(
                        _backgroundAnimation.value * 2 * 3.14159,
                      ),
                      colors: [
                        AppColors.primaryPurple.withOpacity(0.15),
                        colorScheme.surface,
                        AppColors.primaryPurple.withOpacity(0.08),
                        colorScheme.surface,
                        AppColors.primaryPurple.withOpacity(0.12),
                      ],
                    ),
                  ),
                );
              },
            ),

            ...List.generate(8, (index) {
              return AnimatedBuilder(
                animation: Listenable.merge([
                  _floatingAnimation,
                  _particleAnimation,
                ]),
                builder: (context, child) {
                  final size = 30.0 + (index * 8.0);
                  final opacity = 0.05 + (index * 0.02);
                  final rotationOffset = index * 0.5;

                  return Positioned(
                    top: 80 + (index * 100.0),
                    left:
                        (index % 2 == 0)
                            ? -30
                            : MediaQuery.of(context).size.width - size + 10,
                    child: Transform.translate(
                      offset: Offset(
                        _floatingAnimation.value * (index % 2 == 0 ? 1 : -1),
                        _floatingAnimation.value *
                            0.5 *
                            (index % 3 == 0 ? 1 : -1),
                      ),
                      child: Transform.rotate(
                        angle:
                            (_particleAnimation.value + rotationOffset) *
                            2 *
                            3.14159,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryPurple.withOpacity(opacity),
                                AppColors.primaryPurple.withOpacity(
                                  opacity * 0.3,
                                ),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.primaryPurple.withOpacity(
                                opacity * 2,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            SafeArea(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  if (state is OnboardingInProgress) {
                    return Column(
                      children: [
                        AnimatedBuilder(
                          animation: _headerAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                -30 * (1 - _headerAnimation.value),
                              ),
                              child: Opacity(
                                // Clamp because Curves.elasticOut can overshoot outside 0..1
                                opacity: (_headerAnimation.value).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.surface.withOpacity(0.9),
                                        colorScheme.surface.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.primaryPurple
                                          .withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.15),
                                        blurRadius: 25,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(-5, -5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (state.currentPage > 0)
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(
                                            milliseconds: 400,
                                          ),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primaryPurple
                                                          .withOpacity(0.15),
                                                      AppColors.primaryPurple
                                                          .withOpacity(0.1),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .primaryPurple
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: IconButton(
                                                  onPressed: _previousPage,
                                                  icon: const Icon(
                                                    Icons.arrow_back_ios,
                                                    size: 20,
                                                  ),
                                                  color:
                                                      AppColors.primaryPurple,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        const SizedBox(width: 56),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primaryPurple
                                                  .withOpacity(0.1),
                                              AppColors.primaryPurple
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primaryPurple
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        child: ShaderMask(
                                          shaderCallback:
                                              (bounds) => LinearGradient(
                                                colors: [
                                                  AppColors.primaryPurple,
                                                  AppColors.primaryPurple
                                                      .withOpacity(0.7),
                                                ],
                                              ).createShader(bounds),
                                          child: Text(
                                            '${state.currentPage + 1} / ${state.totalPages}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (!state.isLastPage)
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                colorScheme.surface.withOpacity(
                                                  0.8,
                                                ),
                                                colorScheme.surface.withOpacity(
                                                  0.6,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.outline
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: TextButton(
                                            onPressed: _skipOnboarding,
                                            child: Text(
                                              'Skip',
                                              style: TextStyle(
                                                color: colorScheme.onSurface
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(width: 56),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              context.read<OnboardingCubit>().changePage(
                                index,
                                _onboardingPages.length,
                              );
                            },
                            itemCount: _onboardingPages.length,
                            itemBuilder: (context, index) {
                              return Hero(
                                tag: 'onboarding_page_$index',
                                child: OnboardingPageWidget(
                                  page: _onboardingPages[index],
                                  isActive: index == state.currentPage,
                                  pageIndex: index,
                                ),
                              );
                            },
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.surface.withOpacity(0.9),
                                colorScheme.surface.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryPurple.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: OnboardingIndicator(
                            currentIndex: state.currentPage,
                            totalPages: state.totalPages,
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.95 + (0.05 * value),
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primaryPurple,
                                        AppColors.primaryPurple.withOpacity(
                                          0.8,
                                        ),
                                        AppColors.primaryPurple.withOpacity(
                                          0.9,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.4),
                                        blurRadius: 25,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: AppColors.primaryPurple
                                            .withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        state.isLastPage
                                            ? _completeOnboarding
                                            : _nextPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          state.isLastPage
                                              ? 'Get Started'
                                              : 'Continue',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        TweenAnimationBuilder<double>(
                                          duration: const Duration(
                                            milliseconds: 1000,
                                          ),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          builder: (context, iconValue, child) {
                                            return Transform.translate(
                                              offset: Offset(iconValue * 5, 0),
                                              child: Icon(
                                                state.isLastPage
                                                    ? Icons
                                                        .rocket_launch_rounded
                                                    : Icons
                                                        .arrow_forward_rounded,
                                                size: 22,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.surface.withOpacity(0.9),
                            colorScheme.surface.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primaryPurple.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
