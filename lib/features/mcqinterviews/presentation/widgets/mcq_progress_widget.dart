import 'package:flutter/material.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_state.dart';

class McqProgressWidget extends StatelessWidget {
  final McqInterviewInProgressState state;

  const McqProgressWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.currentQuestionIndex + 1} of ${state.questions.length}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
