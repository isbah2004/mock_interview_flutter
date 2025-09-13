import 'package:flutter/material.dart';

import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_state.dart';

class QuestionDisplayWidget extends StatelessWidget {
  final VoiceInterviewReady state;
  final String currentQuestion;

  const QuestionDisplayWidget({
    super.key,
    required this.state,
    required this.currentQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        //     blurRadius: 15,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Interview Question',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          state.isProcessing
              ? Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Loading question...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
              : Text(
                currentQuestion,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
        ],
      ),
    );
  }
}
