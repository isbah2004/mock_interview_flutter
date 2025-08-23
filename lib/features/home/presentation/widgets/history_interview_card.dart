import 'package:flutter/material.dart';

class HistoryInterviewCard extends StatelessWidget {
  final Map<String, dynamic> interview;

  const HistoryInterviewCard({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            _InterviewIconContainer(icon: interview['icon']),
            const SizedBox(width: 20),
            Expanded(
              child: _InterviewDetails(
                type: interview['type'],
                date: interview['date'],
                duration: interview['duration'],
              ),
            ),
            _InterviewScore(score: interview['score']),
          ],
        ),
      ),
    );
  }
}

class _InterviewIconContainer extends StatelessWidget {
  final IconData icon;

  const _InterviewIconContainer({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: theme.colorScheme.onPrimary, size: 26),
    );
  }
}

class _InterviewDetails extends StatelessWidget {
  final String type;
  final String date;
  final String duration;

  const _InterviewDetails({
    required this.type,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        _InterviewMetadata(date: date, duration: duration),
      ],
    );
  }
}

class _InterviewMetadata extends StatelessWidget {
  final String date;
  final String duration;

  const _InterviewMetadata({
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Text(
          _formatDate(date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time_rounded,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Text(
          duration,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InterviewScore extends StatelessWidget {
  final int score;

  const _InterviewScore({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$score',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        _ScoreBadge(score: score),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getScoreColor(score, theme),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getScoreLabel(score),
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getScoreColor(int score, ThemeData theme) {
    if (score >= 90) return theme.colorScheme.primary;
    if (score >= 80) return theme.colorScheme.primary.withOpacity(0.8);
    return theme.colorScheme.primary.withOpacity(0.6);
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    return 'Average';
  }
}
