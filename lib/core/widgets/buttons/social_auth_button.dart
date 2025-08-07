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
required this. onTap,
    required this.isLoading,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 55,
        width: width ?? context.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surface,
        ),
        child:
            isLoading
                ? CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Theme.of(context).colorScheme.primary,
                )
                : Text(
                  type == SocialAuthType.google ? 'Continue with Google' : 'Continue with Facebook',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
