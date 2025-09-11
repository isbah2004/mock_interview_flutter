import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/home/presentation/widgets/stat_card.dart';
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/cubits/usercubit/user_state.dart';
import '../../../../core/constants/app_strings.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        // Default values
        int totalInterviews = 0;
        double averageScore = 0.0;
        int voiceInterviews = 0;
        int mcqInterviews = 0;

        // Get values from user state
        if (state is UserAvailable) {
          totalInterviews = state.user.totalInterviews;
          averageScore = state.user.averageScore;
          voiceInterviews = state.user.voiceInterviews;
          mcqInterviews = state.user.mcqInterviews;
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
          children: [
            StatCard(
              title: AppStrings.totalInterviews,
              value: totalInterviews.toString(),
              icon: Icons.calendar_today_rounded,
              gradientColors:
                  isDark ? AppColors.darkGradient : AppColors.lightGradient,
              accentColor: AppColors.primaryPurple,
            ),
            StatCard(
              title: AppStrings.averageScore,
              value: averageScore.toStringAsFixed(1),
              icon: Icons.emoji_events_rounded,
              gradientColors:
                  isDark ? AppColors.darkGradient : AppColors.lightGradient,
              accentColor: AppColors.success,
            ),
            StatCard(
              title: AppStrings.voiceInterviews,
              value: voiceInterviews.toString(),
              icon: Icons.mic_rounded,
              gradientColors:
                  isDark ? AppColors.darkGradient : AppColors.lightGradient,
              accentColor: AppColors.info,
            ),
            StatCard(
              title: AppStrings.mcqInterviews,
              value: mcqInterviews.toString(),
              icon: Icons.quiz_rounded,
              gradientColors:
                  isDark ? AppColors.darkGradient : AppColors.lightGradient,
              accentColor: AppColors.warning,
            ),
          ],
        );
      },
    );
  }
}
