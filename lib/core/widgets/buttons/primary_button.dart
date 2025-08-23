import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final bool isOutlined;
  
  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.title,
    this.isLoading = false,
    this.width,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: width ?? double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isOutlined ? null : LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: isOutlined ? Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ) : null,
        boxShadow: !isOutlined ? [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOutlined 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isOutlined 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isOutlined 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
