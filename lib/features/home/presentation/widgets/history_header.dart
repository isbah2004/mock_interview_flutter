import 'package:flutter/material.dart';
import 'history_stat_card.dart';
import '../../../../../core/theme/colorpalette/light_theme.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Interview History',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          const HistoryStatsGrid(),
        ],
      ),
    );
  }
}

class HistoryStatsGrid extends StatelessWidget {
  const HistoryStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HistoryStatCard(
            value: '87',
            label: 'Avg Score',
            icon: Icons.emoji_events,
            gradientColors: [
              LightThemePalette.gray700,
              LightThemePalette.gray900,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HistoryStatCard(
            value: '5',
            label: 'Total',
            icon: Icons.calendar_today,
            gradientColors: [
              LightThemePalette.gray600,
              LightThemePalette.gray700,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HistoryStatCard(
            value: '+12%',
            label: 'Growth',
            icon: Icons.trending_up,
            gradientColors: [
              LightThemePalette.gray500,
              LightThemePalette.gray600,
            ],
          ),
        ),
      ],
    );
  }
}
