import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/home/presentation/widgets/stat_card.dart';
import '../../../../core/constants/app_strings.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          value: '0',
          icon: Icons.calendar_today_rounded,
          gradientColors:
              isDark ? AppColors.darkGradient : AppColors.lightGradient,
          accentColor: AppColors.primaryPurple,
        ),
        StatCard(
          title: AppStrings.averageScore,
          value: '0.0',
          icon: Icons.emoji_events_rounded,
          gradientColors:
              isDark ? AppColors.darkGradient : AppColors.lightGradient,
          accentColor: AppColors.success,
        ),
        StatCard(
          title: AppStrings.voiceInterviews,
          value: '0',
          icon: Icons.mic_rounded,
          gradientColors:
              isDark ? AppColors.darkGradient : AppColors.lightGradient,
          accentColor: AppColors.info,
        ),
        StatCard(
          title: AppStrings.mcqInterviews,
          value: '0',
          icon: Icons.quiz_rounded,
          gradientColors:
              isDark ? AppColors.darkGradient : AppColors.lightGradient,
          accentColor: AppColors.warning,
        ),
      ],
    );
  }
}
