import 'package:flutter/material.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_state.dart';

class VoiceInputWidget extends StatelessWidget {
  final VoiceInterviewReady state;

  const VoiceInputWidget({
    super.key,

     required this.state
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.currentListeningText != null &&
              state.currentListeningText!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withAlpha(70),
                width: 1,
              ),
            ),
            child: Text(
              state.currentListeningText!,
              // 'lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.start,
              maxLines: null,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
