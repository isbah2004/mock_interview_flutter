import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final bool showSpinner;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
