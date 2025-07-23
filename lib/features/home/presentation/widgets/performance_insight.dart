import 'package:flutter/material.dart';
import '../../../../core/theme/colorpalette/light_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/entities/user_stats.dart';
import 'custom_card.dart';

class PerformanceInsight extends StatelessWidget {
  final UserStats? userStats;

  const PerformanceInsight({super.key, this.userStats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = userStats;
    final improvement = stats?.improvementPercentage ?? 0.0;

    return CustomCard(
      gradient: LinearGradient(
        colors: [LightThemePalette.gray100, theme.colorScheme.surface],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      LightThemePalette.gray700,
                      LightThemePalette.gray600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.performanceInsight,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    improvement > 0
                        ? AppStrings.youreDoingGreat
                        : 'Keep practicing!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            improvement > 0
                ? 'Your interview skills have improved by ${improvement.toStringAsFixed(1)}% this month. Keep practicing to maintain your momentum!'
                : 'Start taking more interviews to see your improvement trends and performance insights.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.track_changes,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  improvement > 0 ? AppStrings.onTrack : 'Getting Started',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
