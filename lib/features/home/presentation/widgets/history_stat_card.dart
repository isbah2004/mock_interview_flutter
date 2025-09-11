import 'package:flutter/material.dart';
import 'package:mock_interview/features/home/data/models/history_stat_model.dart';
import 'package:mock_interview/core/utils/color_compat.dart';

class HistoryStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isPrimary;

  const HistoryStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.isPrimary = false,
  });

  HistoryStatCard.fromModel({super.key, required HistoryStatModel model})
    : value = model.value,
      label = model.label,
      icon = model.icon,
      isPrimary = model.isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient:
            isPrimary
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacityCompat(0.8),
                  ],
                )
                : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHigh,
                  ],
                ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isPrimary
                  ? Colors.transparent
                  : theme.colorScheme.primary.withOpacityCompat(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isPrimary
                    ? theme.colorScheme.primary.withOpacityCompat(0.3)
                    : theme.colorScheme.shadow.withOpacityCompat(0.06),
            blurRadius: isPrimary ? 16 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isPrimary
                      ? theme.colorScheme.onPrimary.withOpacityCompat(0.2)
                      : theme.colorScheme.primary.withOpacityCompat(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color:
                  isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color:
                  isPrimary
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isPrimary
                      ? theme.colorScheme.onPrimary.withOpacityCompat(0.9)
                      : theme.colorScheme.onSurface.withOpacityCompat(0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
