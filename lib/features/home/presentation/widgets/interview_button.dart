import 'package:flutter/material.dart';
import '../../../../../core/theme/colorpalette/light_theme.dart';

enum InterviewButtonType { primary, secondary }

class InterviewButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;
  final InterviewButtonType type;

  const InterviewButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onPressed,
    this.type = InterviewButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.only(bottom: 16),
      child:
          type == InterviewButtonType.primary
              ? PrimaryInterviewButton(
                title: title,
                subtitle: subtitle,
                icon: icon,
                onPressed: onPressed,
              )
              : SecondaryInterviewButton(
                title: title,
                subtitle: subtitle,
                icon: icon,
                onPressed: onPressed,
              ),
    );
  }
}

class PrimaryInterviewButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;

  const PrimaryInterviewButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, LightThemePalette.gray900],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InterviewButtonIcon(
                icon: icon,
                backgroundColor: Colors.white.withOpacity(0.1),
                iconColor: Colors.white,
              ),
              const SizedBox(width: 12),
              InterviewButtonText(
                title: title,
                subtitle: subtitle,
                titleColor: Colors.white,
                subtitleColor: LightThemePalette.gray100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondaryInterviewButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;

  const SecondaryInterviewButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: theme.dividerColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: theme.colorScheme.onSurface.withOpacity(0.1),
        elevation: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InterviewButtonIcon(
            icon: icon,
            backgroundColor: theme.colorScheme.onPrimary,
            iconColor: LightThemePalette.gray700,
          ),
          const SizedBox(width: 12),
          InterviewButtonText(
            title: title,
            subtitle: subtitle,
            titleColor: theme.colorScheme.primary,
            subtitleColor: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class InterviewButtonIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const InterviewButtonIcon({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class InterviewButtonText extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  const InterviewButtonText({
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
        ),
      ],
    );
  }
}
