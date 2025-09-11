import 'package:flutter/material.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/core/utils/color_compat.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color>? gradientColors;
  final Color? accentColor;
  final double? width;
  final double? height;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.gradientColors,
    this.accentColor,
    this.width,
    this.height,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.accentColor ?? AppColors.primaryPurple;

    return GestureDetector(
      onTap: () {
        // Removed animation
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.gradientColors ??
                [
                  isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                  isDark
                      ? AppColors.darkSecondaryVariant
                      : AppColors.lightSecondaryVariant,
                ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacityCompat(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacityCompat(0.3)
                      : Colors.black.withOpacityCompat(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: accentColor.withOpacityCompat(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacityCompat(0.2),
                      accentColor.withOpacityCompat(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: accentColor.withOpacityCompat(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(widget.icon, color: accentColor, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color:
                      isDark
                          ? AppColors.darkOnSurface.withOpacityCompat(0.8)
                          : AppColors.lightOnSurface.withOpacityCompat(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color:
                      isDark
                          ? AppColors.darkOnBackground
                          : AppColors.lightOnBackground,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
