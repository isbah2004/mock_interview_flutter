import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import 'package:mock_interview/features/home/data/models/interview_history_model.dart';
import 'package:mock_interview/features/home/presentation/widgets/gradient_background.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_header.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_interview_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/history/presentation/cubit/history_cubit.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/cubits/usercubit/user_state.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserCubit>().currentUser?.id;
      dev.log('HistoryTab initState - userId: $userId', name: 'HistoryTab');
      if (userId != null &&
          context.read<HistoryCubit>().state is HistoryInitial) {
        context.read<HistoryCubit>().load(userId);
      }
    });
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null) return '-- min';
    final minutes = (durationInSeconds / 60).round();
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listenWhen:
          (prev, curr) => prev is! UserAvailable && curr is UserAvailable,
      listener: (context, state) {
        if (state is UserAvailable) {
          final userId = state.user.id;
          final historyState = context.read<HistoryCubit>().state;
          final shouldLoad =
              historyState is HistoryInitial ||
              (historyState is HistoryLoaded &&
                  historyState.sessions.isEmpty) ||
              historyState is HistoryError;
          if (shouldLoad) {
            dev.log(
              'User became available, loading history for $userId',
              name: 'HistoryTab',
            );
            context.read<HistoryCubit>().load(userId);
          }
        }
      },
      child: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const HistoryHeader(),
              Expanded(
                child: BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryPurpleLight,
                          ),
                        ),
                      );
                    } else if (state is HistoryError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else if (state is HistoryLoaded) {
                      // Filter only completed interviews
                      final completedSessions =
                          state.sessions
                              .where((session) => session.isCompleted)
                              .toList();

                      if (completedSessions.isEmpty) {
                        return _buildEnhancedEmptyState();
                      }
                      final display =
                          completedSessions.map((s) {
                            return {
                              'id': s.sessionId,
                              // use normalized type strings that the model parser expects
                              'type':
                                  s.interviewType == 'voice' ? 'voice' : 'mcq',
                              'jobRole': s.jobRole,
                              'category': s.category,
                              'difficulty': s.difficulty,
                              'date': _formatDate(s.startedAt),
                              'duration': _formatDuration(s.duration),
                              'score': (s.percentage ?? 0).round(),
                              'finalScore': s.score ?? 0.0,
                              // normalized status values expected by the parser
                              'status':
                                  s.isCompleted ? 'completed' : 'in_progress',
                              'isComplete': s.isCompleted,
                              'passed': s.passed ?? false,
                              'totalQuestions': s.totalQuestions,
                              'icon':
                                  s.interviewType == 'voice'
                                      ? Icons.mic
                                      : Icons.quiz,
                              'startedAt': s.startedAt,
                              // serialize completedAt to ISO string to match fromMap expectation
                              'completedAt': s.completedAt?.toIso8601String(),
                              // Store session data for navigation
                              'sessionData': s,
                            };
                          }).toList();

                      // Convert legacy map list into strongly-typed models
                      final interviews =
                          display
                              .map((m) => InterviewHistoryModel.fromMap(m))
                              .toList();

                      return HistoryInterviewList(interviewHistory: interviews);
                    }
                    // HistoryInitial fallback
                    final hasUser = context.read<UserCubit>().hasUser;
                    if (!hasUser) {
                      return _buildEnhancedEmptyState(
                        message: 'Sign in to see your interview history',
                      );
                    }
                    return _buildEnhancedEmptyState();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState({String? message}) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurpleLight.withOpacityCompat(0.05),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),

            //
            // BoxShadow(
            //   color: Colors.black.withOpacity(0.2),
            //   blurRadius: 10,
            //   offset: const Offset(-5, -5),
            // ),
            // BoxShadow(
            //   color: Colors.grey.withOpacity(0.05),
            //   blurRadius: 10,
            //   offset: const Offset(5, 5),
            // ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurpleLight.withOpacityCompat(0.2),
                    AppColors.primaryPurpleLight.withOpacityCompat(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.history,
                size: 40,
                color: AppColors.primaryPurpleLight,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'No interview history yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first interview to see it here',
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacityCompat(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userId = context.read<UserCubit>().currentUser?.id;
                if (userId != null) {
                  context.read<HistoryCubit>().load(userId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurpleLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Refresh',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
