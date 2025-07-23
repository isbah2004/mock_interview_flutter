import 'package:flutter/material.dart';
import '../../../../core/theme/colorpalette/light_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

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
              [
                LightThemePalette.gray100,
                theme.colorScheme.surface,
                LightThemePalette.gray100,
              ],
        ),
      ),
      child: child,
    );
  }
}
