import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_state.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_event.dart';

class BottomBarWidget extends StatelessWidget {
  final VoiceInterviewReady state;
  final TextEditingController transcriptController;
  final Animation<double> pulseAnimation;

  const BottomBarWidget({
    super.key,
    required this.state,
    required this.transcriptController,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final wordCount =
        transcriptController.text.trim().isEmpty
            ? 0
            : transcriptController.text.trim().split(' ').length;
    final canSubmit =
        !state.isProcessing &&
        transcriptController.text.trim().isNotEmpty &&
        wordCount >= 10;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildSleekTTSButton(
                context,
                _getTTSIcon(state),
                _getTTSLabel(state),
                () => _handleTTSToggle(context, state),
                _getTTSButtonActiveState(state),
              ),

              const SizedBox(width: 20),

              _buildSleekMicrophoneButton(context, state),

              const SizedBox(width: 20),

              Expanded(
                child: _buildSleekSubmitButton(
                  context,
                  state,
                  canSubmit,
                  wordCount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleekMicrophoneButton(
    BuildContext context,
    VoiceInterviewReady state,
  ) {
    return GestureDetector(
      onTap:
          state.isProcessing
              ? null
              : () {
                if (state.isListening) {
                  context.read<VoiceInterviewBloc>().add(StopListening());
                } else {
                  context.read<VoiceInterviewBloc>().add(StartListening());
                }
              },
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: state.isListening ? pulseAnimation.value : 1.0,
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors:
                      state.isListening
                          ? [Colors.red.shade400, Colors.red.shade600]
                          : [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        state.isListening
                            ? Colors.red.withOpacity(0.4)
                            : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.4),
                    blurRadius: state.isListening ? 20 : 12,
                    spreadRadius: state.isListening ? 4 : 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (state.isListening)
                    AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          height: 64 + (20 * pulseAnimation.value),
                          width: 64 + (20 * pulseAnimation.value),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                ((1 - pulseAnimation.value).clamp(0.0, 1.0) *
                                        0.3)
                                    .toDouble(),
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  Icon(
                    state.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSleekSubmitButton(
    BuildContext context,
    VoiceInterviewReady state,
    bool canSubmit,
    int wordCount,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitTranscript(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient:
                canSubmit
                    ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    )
                    : LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ],
                    ),
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                canSubmit
                    ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Container(
            alignment: Alignment.center,
            child:
                state.isProcessing
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          canSubmit ? Icons.send_rounded : Icons.lock_rounded,
                          size: 18,
                          color:
                              canSubmit
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            canSubmit ? 'Submit' : '\$wordCount/10',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color:
                                  canSubmit
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSleekTTSButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        gradient:
            isActive
                ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                )
                : LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.8),
                    Theme.of(context).colorScheme.surfaceContainerLowest,
                  ],
                ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              color:
                  isActive
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for TTS button state
  IconData _getTTSIcon(VoiceInterviewReady state) {
    if (state.isSpeaking && !state.isSpeakingPaused) {
      return Icons.pause_rounded;
    } else if (state.isSpeakingPaused) {
      return Icons.play_arrow_rounded;
    } else {
      return Icons.volume_up_rounded;
    }
  }

  String _getTTSLabel(VoiceInterviewReady state) {
    if (state.isSpeaking && !state.isSpeakingPaused) {
      return 'Pause';
    } else if (state.isSpeakingPaused) {
      return 'Resume';
    } else {
      return 'Listen';
    }
  }

  bool _getTTSButtonActiveState(VoiceInterviewReady state) {
    return state.isSpeaking || state.isSpeakingPaused;
  }

  void _handleTTSToggle(BuildContext context, VoiceInterviewReady state) {
    final bloc = context.read<VoiceInterviewBloc>();

    if (state.isSpeaking && !state.isSpeakingPaused) {
      bloc.add(PauseTTS());
    } else {
      bloc.add(PlayTTS());
    }
  }

  void _submitTranscript(BuildContext context) {
    final bloc = context.read<VoiceInterviewBloc>();
    final transcript = transcriptController.text.trim();
    bloc.add(SendUserResponse(transcript));
    transcriptController.clear();
  }
}
