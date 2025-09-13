import 'package:flutter/material.dart';
import 'package:mock_interview/features/mcqinterviews/presentation/bloc/unified_mcq_interview_state.dart';

class McqSavingWidget extends StatelessWidget {
  final SavingInterviewResultState state;
  final Animation<double> pulseAnimation;

  const McqSavingWidget({
    super.key,
    required this.state,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: pulseAnimation.value,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 6,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.7 + (pulseAnimation.value * 0.3),
                    child: Text(
                      'Processing Your Results',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              Text(
                'Evaluating ${state.questions.length} questions...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: pulseAnimation,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final animationValue =
                          (pulseAnimation.value + delay) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(0.3 + (animationValue * 0.7)),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
