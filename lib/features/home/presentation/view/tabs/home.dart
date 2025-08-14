import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/di/injection_container.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mock_interview/features/auth/presentation/bloc/auth_state.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_bloc.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_event.dart';
import 'package:mock_interview/features/home/presentation/bloc/home_state.dart';
import '../../widgets/widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<HomeBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            // Load user stats when authenticated
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
                              // Header
                              HomeHeader(
                                userId:
                                 'User',
                              ),
                              const SizedBox(height: 32),

                              // Stats Grid
                              if (homeState is HomeLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (homeState is HomeLoaded)
                                StatsGrid()
                              else if (homeState is HomeError)
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Error loading stats',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        homeState.message,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (authState is AuthAuthenticated) {
                                            context.read<HomeBloc>().add(
                                              HomeRefreshRequested(
                                                userId: authState.user.id,
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const StatsGrid(),

                              const SizedBox(height: 32),

                              // Quick Actions
                              const QuickActions(),
                              const SizedBox(height: 32),

                              // Performance Insight
                              PerformanceInsight(
                                
                              ),
                              const SizedBox(
                                height: 100,
                              ), // Space for bottom nav
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
}
