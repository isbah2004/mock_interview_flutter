import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final bool elevated;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: border ?? Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: boxShadow ?? (elevated ? [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}
