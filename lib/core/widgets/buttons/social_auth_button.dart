import 'package:flutter/material.dart';
import 'package:mock_interview/core/enums/social_auth_type.dart';
import 'package:mock_interview/core/utils/extensions/media_query_extension.dart';

class SocialAuthButton extends StatelessWidget {
  final SocialAuthType type;
  final bool isLoading;
  final double? width;
  final VoidCallback onTap;
  
  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onTap,
    required this.isLoading,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          height: 56,
          width: width ?? context.width,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type == SocialAuthType.google 
                          ? Icons.g_mobiledata 
                          : Icons.facebook,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      type == SocialAuthType.google 
                          ? 'Continue with Google' 
                          : 'Continue with Facebook',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
