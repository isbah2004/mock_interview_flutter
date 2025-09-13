import 'package:flutter/material.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_state.dart';

class VoiceInputWidget extends StatelessWidget {
  final VoiceInterviewReady state;
  final Animation<double> pulseAnimation;
  final Animation<double> waveAnimation;

  const VoiceInputWidget({
    super.key,
    required this.state,
    required this.pulseAnimation,
    required this.waveAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: state.isListening ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    return AnimatedBuilder(
                      animation: waveAnimation,
                      builder: (context, child) {
                        final delay = index * 0.1;
                        final animValue = ((waveAnimation.value + delay) % 1.0);
                        final height = 8 + (25 * animValue);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 3,
                          height: height,
                          decoration: BoxDecoration(
                            color: Colors.red.shade400.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (state.currentListeningText != null &&
                state.currentListeningText!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.currentListeningText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
