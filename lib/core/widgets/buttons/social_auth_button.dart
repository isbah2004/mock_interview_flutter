import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/extensions/media_query_extension.dart';

class SocialAuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final bool isLoading;
  final double? width;
  const SocialAuthButton({
    super.key,
    required this.onTap,
    required this.title,
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
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
