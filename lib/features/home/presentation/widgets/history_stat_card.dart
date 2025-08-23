import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isPrimary 
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isPrimary 
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.onSurface.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPrimary 
                    ? theme.colorScheme.onPrimary.withOpacity(0.2)
                    : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isPrimary 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPrimary 
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isPrimary 
                    ? theme.colorScheme.onPrimary.withOpacity(0.8)
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
