import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/extensions/media_query_extension.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final bool isLoading;
  final double? width;
  const PrimaryButton({
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
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.primary,
        ),
        child:
            isLoading
                ?  CircularProgressIndicator(
                  strokeWidth: 2.0, 
                  color: Theme.of(context).colorScheme.surface,
                )
                : Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
