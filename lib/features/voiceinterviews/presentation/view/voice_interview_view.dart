import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mock_interview/core/widgets/loading_overlay.dart';
import 'package:mock_interview/core/widgets/error_dialog.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_event.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_state.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_session.dart';
import 'package:mock_interview/features/voiceinterviews/domain/entities/interview_message.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/widgets/progress_tracker_widget.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/widgets/question_display_widget.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/widgets/voice_input_widget.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/widgets/bottom_bar_widget.dart';

class VoiceInterviewScreen extends StatefulWidget {
  final String sessionId;

  const VoiceInterviewScreen({super.key, required this.sessionId});

  @override
  State<VoiceInterviewScreen> createState() => _VoiceInterviewScreenState();
}

class _VoiceInterviewScreenState extends State<VoiceInterviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  final TextEditingController _transcriptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _transcriptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEndInterviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            contentPadding: const EdgeInsets.all(24),
            title: Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'End Interview?',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Are you sure you want to end the interview? This action cannot be undone and your progress will be lost.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.read<VoiceInterviewBloc>().add(
                            EndInterview(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'End Interview',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  // Submission logic moved to BottomBarWidget

  String _getCurrentQuestion(InterviewSession session) {
    final aiMessages =
        session.messages
            .where((message) => message.type == MessageType.ai)
            .toList();

    if (aiMessages.isNotEmpty) {
      return aiMessages.last.content;
    }
    return 'Loading question...';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoiceInterviewBloc, VoiceInterviewState>(
      listener: (context, state) {
        if (state is VoiceInterviewError) {
          showDialog(
            context: context,
            builder:
                (context) => ErrorDialog(
                  title: 'Interview Error',
                  message: state.message,
                  onRetry: () {
                    context.read<VoiceInterviewBloc>().add(
                      RetryCurrentQuestion(),
                    );
                  },
                ),
          );
        } else if (state is VoiceInterviewCompleted) {
          Navigator.of(context).pushReplacementNamed(
            '/voice-result',
            arguments: {
              'session': state.session,
              'config': state.session.config,
              'evaluation': state.evaluation,
            },
          );
        } else if (state is VoiceInterviewEvaluated) {
          Navigator.of(context).pushReplacementNamed(
            '/voice-result',
            arguments: {
              'session': state.session,
              'config': state.session.config,
              'evaluation': state.result,
            },
          );
        } else if (state is VoiceInterviewReady) {
          if (state.currentListeningText != null &&
              state.currentListeningText != _transcriptController.text) {
            _transcriptController.text = state.currentListeningText!;
            _transcriptController.selection = TextSelection.fromPosition(
              TextPosition(offset: _transcriptController.text.length),
            );
          }

          final isLastQuestion =
              state.session.currentQuestionNumber ==
              state.session.config.numberOfQuestions;
          if (isLastQuestion &&
              state.currentListeningText == null &&
              !state.isListening &&
              _transcriptController.text.isNotEmpty) {
            // Keep existing text for final question
          }

          if (state.isListening) {
            if (!_pulseController.isAnimating) {
              _pulseController.repeat(reverse: true);
            }
            if (!_waveController.isAnimating) {
              _waveController.repeat();
            }
          } else {
            if (_pulseController.isAnimating) {
              _pulseController.stop();
              _pulseController.reset();
            }
            if (_waveController.isAnimating) {
              _waveController.stop();
              _waveController.reset();
            }
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,

          body: SafeArea(child: _buildBody(context, state)),
          bottomNavigationBar:
              state is VoiceInterviewReady
                  ? BottomBarWidget(
                    state: state,
                    transcriptController: _transcriptController,
                    pulseAnimation: _pulseAnimation,
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, VoiceInterviewState state) {
    if (state is VoiceInterviewLoading) {
      return const LoadingOverlay(message: 'Initializing interview...');
    }

    if (state is VoiceInterviewReady) {
      return SafeArea(child: _buildInterviewContent(state));
    }

    if (state is VoiceInterviewError) {
      return SafeArea(child: _buildErrorContent(context, state));
    }

    return const LoadingOverlay(message: 'Loading...');
  }

  Widget _buildInterviewContent(VoiceInterviewReady state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Column(
                children: [
                  ProgressTrackerWidget(state: state),
                  const SizedBox(height: 20),
                  QuestionDisplayWidget(
                    state: state,
                    currentQuestion: _getCurrentQuestion(state.session),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildSleekTranscript(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Replaced by ProgressTrackerWidget and QuestionDisplayWidget

  Widget _buildSleekTranscript(
    BuildContext context,
    VoiceInterviewReady state,
  ) {
    return VoiceInputWidget(
      state: state,
      pulseAnimation: _pulseAnimation,
      waveAnimation: _waveAnimation,
    );
  }

  // Old voice input implementation removed - replaced by VoiceInputWidget

  Widget _buildErrorContent(BuildContext context, VoiceInterviewError state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.error.withOpacity(0.1),
                        Theme.of(context).colorScheme.error.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Interview Error',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showEndInterviewDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'End Interview',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<VoiceInterviewBloc>().add(
                            RetryCurrentQuestion(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bottom bar and helpers moved to BottomBarWidget
}
