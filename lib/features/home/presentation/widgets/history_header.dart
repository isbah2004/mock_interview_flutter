import 'package:flutter/material.dart';
import 'package:mock_interview/features/home/presentation/widgets/history_stat_card.dart';

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
            style: theme.textTheme.headlineMedium?.copyWith(
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
            icon: Icons.emoji_events_rounded,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HistoryStatCard(
            value: '5',
            label: 'Total',
            icon: Icons.calendar_today_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: HistoryStatCard(
            value: '+12%',
            label: 'Growth',
            icon: Icons.trending_up_rounded,
          ),
        ),
      ],
    );
  }
}
