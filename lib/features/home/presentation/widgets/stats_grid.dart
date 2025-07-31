import 'package:flutter/material.dart';
import '../../../../core/theme/colorpalette/light_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/entities/user_stats.dart';
import 'stat_card.dart';

class StatsGrid extends StatelessWidget {
  final UserStats? userStats;

  const StatsGrid({super.key, this.userStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = userStats;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1,
      children: [
        StatCard(
          title: AppStrings.totalInterviews,
          value: stats?.totalInterviews.toString() ?? '0',
          icon: Icons.calendar_today,
          gradientColors: [
            theme.colorScheme.primary,
            LightThemePalette.gray700,
          ],
        ),
        StatCard(
          title: AppStrings.averageScore,
          value: stats?.averageScore.toStringAsFixed(1) ?? '0.0',
          icon: Icons.emoji_events,
          gradientColors: [
            LightThemePalette.gray700,
            LightThemePalette.gray600,
          ],
        ),
        StatCard(
          title: AppStrings.voiceInterviews,
          value: stats?.voiceInterviews.toString() ?? '0',
          icon: Icons.mic,
          gradientColors: [
            LightThemePalette.gray600,
            LightThemePalette.gray500,
          ],
        ),
        StatCard(
          title: AppStrings.mcqInterviews,
          value: stats?.mcqInterviews.toString() ?? '0',
          icon: Icons.book,
          gradientColors: [
            LightThemePalette.gray500,
            LightThemePalette.gray400,
          ],
        ),
      ],
    );
  }
}
