import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_state.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_bloc.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_event.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_state.dart';
import 'package:mock_interview/features/home/presentation/widgets/gradient_background.dart';
import 'package:mock_interview/features/home/presentation/widgets/home_header.dart';
import 'package:mock_interview/features/home/presentation/widgets/performance_insight.dart';
import 'package:mock_interview/features/home/presentation/widgets/stats_grid.dart';
import 'package:mock_interview/features/home/presentation/widgets/widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<HomeBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            context.read<HomeBloc>().add(
              HomeLoadRequested(userId: authState.user.id),
            );
          }

          return GradientBackground(
            child: SafeArea(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, homeState) {
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Enhanced Header
                              const HomeHeader(userId: 'User'),
                              const SizedBox(height: 32),

                              // Enhanced Stats Grid
                              if (homeState is HomeLoading)
                                Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryPurple,
                                    ),
                                  ),
                                )
                              else if (homeState is HomeLoaded)
                                const StatsGrid()
                              else if (homeState is HomeError)
                                _buildErrorState(context, homeState, authState)
                              else
                                const StatsGrid(),

                              const SizedBox(height: 32),

                              // Enhanced Quick Actions
                              QuickActions(),
                              const SizedBox(height: 32),

                              // Enhanced Performance Insight
                              const PerformanceInsight(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    HomeError homeState,
    AuthState authState,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.lightSurface, AppColors.lightSecondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading stats',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeState.message,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (authState is AuthAuthenticated) {
                context.read<HomeBloc>().add(
                  HomeRefreshRequested(userId: authState.user.id),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurpleLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickActions(BuildContext context) {
  //   final textTheme = Theme.of(context).textTheme;

  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors:AppColors.lightGradient
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.primaryPurpleLight.withOpacity(0.1),
  //           blurRadius: 15,
  //           offset: const Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Quick Actions',
  //             style: textTheme.titleLarge?.copyWith(
  //               fontWeight: FontWeight.w600,
  //               color: Theme.of(context).colorScheme.onSurface,
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: _buildActionButton(
  //                   context,
  //                   'Start Interview',
  //                   Icons.play_circle_fill,
  //                   AppColors.primaryPurpleLight,
  //                   () {},
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: _buildActionButton(
  //                   context,
  //                   'Practice Mode',
  //                   Icons.fitness_center,
  //                   AppColors.primaryPurple,
  //                   () {},
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
