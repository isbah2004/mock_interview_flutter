import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/color_compat.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final bool subtle;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.subtle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              colors ??
              (subtle
                  ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerLowest,
                    theme.colorScheme.surface,
                  ]
                  : [
                    theme.colorScheme.primary.withOpacityCompat(0.05),
                    theme.colorScheme.surface,
                    theme.colorScheme.primary.withOpacityCompat(0.02),
                  ]),
        ),
      ),
      child: child,
    );
  }
}
