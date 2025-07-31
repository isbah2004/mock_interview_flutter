import 'package:flutter/material.dart';
import '../../../../../core/theme/colorpalette/light_theme.dart';

class HistoryInterviewCard extends StatelessWidget {
  final Map<String, dynamic> interview;

  const HistoryInterviewCard({super.key, required this.interview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            InterviewIconContainer(icon: interview['icon']),
            const SizedBox(width: 16),
            Expanded(
              child: InterviewDetails(
                type: interview['type'],
                date: interview['date'],
                duration: interview['duration'],
              ),
            ),
            InterviewScore(score: interview['score']),
          ],
        ),
      ),
    );
  }
}

class InterviewIconContainer extends StatelessWidget {
  final IconData icon;

  const InterviewIconContainer({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [LightThemePalette.gray600, LightThemePalette.gray700],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class InterviewDetails extends StatelessWidget {
  final String type;
  final String date;
  final String duration;

  const InterviewDetails({
    super.key,
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
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        InterviewMetadata(date: date, duration: duration),
      ],
    );
  }
}

class InterviewMetadata extends StatelessWidget {
  final String date;
  final String duration;

  const InterviewMetadata({
    super.key,
    required this.date,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: LightThemePalette.gray600),
        const SizedBox(width: 4),
        Text(
          _formatDate(date),
          style: theme.textTheme.bodySmall?.copyWith(
            color: LightThemePalette.gray600,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.access_time, size: 16, color: LightThemePalette.gray600),
        const SizedBox(width: 4),
        Text(
          duration,
          style: theme.textTheme.bodySmall?.copyWith(
            color: LightThemePalette.gray600,
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

class InterviewScore extends StatelessWidget {
  final int score;

  const InterviewScore({super.key, required this.score});

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
        const SizedBox(height: 4),
        ScoreBadge(score: score),
      ],
    );
  }
}

class ScoreBadge extends StatelessWidget {
  final int score;

  const ScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getScoreColor(score),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getScoreLabel(score),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return LightThemePalette.gray900;
    if (score >= 80) return LightThemePalette.gray700;
    return LightThemePalette.gray500;
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    return 'Average';
  }
}
