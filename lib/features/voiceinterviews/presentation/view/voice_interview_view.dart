import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mock_interview/core/services/unified_database_service.dart';
import 'package:mock_interview/core/utils/color_compat.dart';
import 'package:mock_interview/core/utils/voice_cleaner.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_event.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/voice_interview_state.dart';
// ...existing imports
import 'package:mock_interview/features/voiceinterviews/presentation/view/interview_result_view.dart';
import '../../domain/entities/interview_config.dart';
import '../../domain/entities/interview_message.dart';
import '../../domain/entities/interview_session.dart';

class VoiceInterviewView extends StatelessWidget {
  final InterviewConfig config;

  const VoiceInterviewView({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
  
    return VoiceInterviewScreen(config: config);
  }
}

class VoiceInterviewScreen extends StatefulWidget {
  final InterviewConfig config;

  const VoiceInterviewScreen({super.key, required this.config});

  @override
  State<VoiceInterviewScreen> createState() => _VoiceInterviewScreenState();
}

class _VoiceInterviewScreenState extends State<VoiceInterviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _listeningAnimationController;
  late AnimationController _speakingAnimationController;
  late AnimationController _micWaveController;

  late Animation<double> _listeningPulseAnimation;
  late Animation<double> _speakingWaveAnimation;

  @override
  void initState() {
    super.initState();

    _listeningAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _speakingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _micWaveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listeningPulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _listeningAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _speakingWaveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _speakingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _listeningAnimationController.dispose();
    _speakingAnimationController.dispose();
    _micWaveController.dispose();
    super.dispose();
  }

  void _updateAnimations(VoiceInterviewState state) {
    if (state is VoiceInterviewReady) {
      if (state.session.isListening) {
        if (!_listeningAnimationController.isAnimating) {
          _listeningAnimationController.repeat(reverse: true);
          _micWaveController.repeat();
        }
      } else {
        _listeningAnimationController.stop();
        _listeningAnimationController.reset();
        _micWaveController.stop();
        _micWaveController.reset();
      }

      if (state.session.isSpeaking && !state.isSpeakingPaused) {
        if (!_speakingAnimationController.isAnimating) {
          _speakingAnimationController.repeat();
        }
      } else {
        _speakingAnimationController.stop();
        _speakingAnimationController.reset();
      }
    } else {
      _listeningAnimationController.stop();
      _speakingAnimationController.stop();
      _micWaveController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Interview'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showEndInterviewDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<VoiceInterviewBloc, VoiceInterviewState>(
        listener: (context, state) {
          _handleStateChanges(context, state);
        },
        builder: (context, state) {
          _updateAnimations(state);

          return Column(
            children: [
              _buildAnimatedStatusBar(state),
              Expanded(child: _buildMessagesList(state)),
              _buildLiveSpeechDisplay(state),
              _buildAnimatedControlButtons(state),
            ],
          );
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, VoiceInterviewState state) {
    if (state is VoiceInterviewError) {
      _showUserFriendlyError(context, state.message);
    } else if (state is VoiceInterviewReady) {
      _handleInterviewCompletion(context, state);
    } else if (state is VoiceInterviewEvaluated) {
      _navigateToResults(context, state);
    }
  }

  void _showUserFriendlyError(BuildContext context, String errorMessage) {
    String userFriendlyMessage = _translateErrorMessage(errorMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(userFriendlyMessage)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _translateErrorMessage(String errorMessage) {
    final message = errorMessage.toLowerCase();

    if (message.contains('connection reset by peer') ||
        message.contains('socketexception') ||
        message.contains('errno = 104')) {
      return 'Network connection lost. Retrying automatically...';
    } else if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (message.contains('503')) {
      return 'AI service temporarily unavailable. Retrying...';
    } else if (message.contains('429')) {
      return 'Too many requests. Please wait a moment.';
    } else if (message.contains('401')) {
      return 'Authentication error. Please contact support.';
    }
    return errorMessage;
  }

  void _handleInterviewCompletion(
    BuildContext context,
    VoiceInterviewReady state,
  ) {
    if (state.session.status == InterviewStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => InterviewResultView(
                  session: state.session,
                  config: widget.config,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    }
  }

  void _navigateToResults(BuildContext context, VoiceInterviewEvaluated state) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Try to fetch the evaluation from database using sessionId
      try {
        final databaseService = GetIt.instance.get<UnifiedDatabaseService>();
        final evaluation = await databaseService.getVoiceEvaluation(
          state.sessionId,
        );

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => InterviewResultView(
                  session: state.session,
                  config: widget.config,
                  existingEvaluation: evaluation,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } catch (e) {
        // If we can't fetch evaluation, navigate anyway but without it
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => InterviewResultView(
                  session: state.session,
                  config: widget.config,
                  existingEvaluation: null,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  Widget _buildAnimatedStatusBar(VoiceInterviewState state) {
    String status = 'Initializing interview...';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle;
    bool isListening = false;
    bool isSpeaking = false;
    int currentQuestion = 0;
    int totalQuestions = 0;

    if (state is VoiceInterviewReady) {
      isListening = state.session.isListening;
      isSpeaking = state.session.isSpeaking;
      currentQuestion = state.session.currentQuestionNumber;
      totalQuestions = state.session.config.numberOfQuestions;

      if (state.session.isListening) {
        status = 'Listening to your response...';
        statusColor = Colors.red;
        statusIcon = Icons.mic;
      } else if (state.session.isSpeaking) {
        status = state.isSpeakingPaused ? 'AI Paused' : 'AI is asking...';
        statusColor = Colors.orange;
        statusIcon = state.isSpeakingPaused ? Icons.pause : Icons.volume_up;
      } else if (state.session.status == InterviewStatus.inProgress) {
        status = 'Ready for your response';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
      }
    } else if (state is VoiceInterviewError) {
      status = _getErrorStatusText(state.message);
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacityCompat(0.1),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withOpacityCompat(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          if (totalQuestions > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Question $currentQuestion of $totalQuestions',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalQuestions > 0 ? currentQuestion / totalQuestions : 0,
              backgroundColor: statusColor.withOpacityCompat(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedStatusIcon(
                isListening,
                isSpeaking,
                statusIcon,
                statusColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isListening || isSpeaking)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacityCompat(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatusIcon(
    bool isListening,
    bool isSpeaking,
    IconData statusIcon,
    Color statusColor,
  ) {
    if (isListening) {
      return AnimatedBuilder(
        animation: _listeningPulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _listeningPulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacityCompat(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
          );
        },
      );
    } else if (isSpeaking) {
      return _buildSpeakingWaveIcon(statusIcon, statusColor);
    } else {
      return Icon(statusIcon, color: statusColor, size: 20);
    }
  }

  Widget _buildSpeakingWaveIcon(IconData statusIcon, Color statusColor) {
    return AnimatedBuilder(
      animation: _speakingWaveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 8),
            ...List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: 3,
                height:
                    12 +
                    (8 *
                        (0.5 +
                            0.5 *
                                math.sin(
                                  (_speakingWaveAnimation.value * 2 * math.pi) +
                                      (index * 0.5),
                                ))),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _getErrorStatusText(String errorMessage) {
    final message = errorMessage.toLowerCase();

    if (message.contains('connection') ||
        message.contains('network') ||
        message.contains('socketexception')) {
      return 'Network Issue - Retrying...';
    }
    return 'Error occurred';
  }

  Widget _buildMessagesList(VoiceInterviewState state) {
    List<InterviewMessage> messages = [];

    if (state is VoiceInterviewReady) {
      messages = state.session.messages;
    }

    if (messages.isEmpty) {
      return const Center(child: Text('Interview starting...'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.type == MessageType.user;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'You' : 'Interviewer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveSpeechDisplay(VoiceInterviewState state) {
    String? currentText;

    if (state is VoiceInterviewReady) {
      currentText = state.currentListeningText;
    }

    if (currentText == null || currentText.isEmpty) {
      return const SizedBox.shrink();
    }

    final cleanedText = VoiceCleaner.cleanVoiceInput(currentText);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Speech:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(cleanedText.isNotEmpty ? cleanedText : currentText),
        ],
      ),
    );
  }

  Widget _buildAnimatedControlButtons(VoiceInterviewState state) {
    bool isListening = false;
    bool isSpeaking = false;
    bool isSpeakingPaused = false;
    bool canListen = false;

    if (state is VoiceInterviewReady) {
      isListening = state.session.isListening;
      isSpeaking = state.session.isSpeaking;
      isSpeakingPaused = state.isSpeakingPaused;
      canListen =
          !isSpeaking && state.session.status == InterviewStatus.inProgress;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isSpeaking) ...[
            _buildEnhancedAIControls(isSpeakingPaused),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEndInterviewButton(),
              if (!isSpeaking)
                _buildEnhancedMicrophoneButton(isListening, canListen),
            ],
          ),
          if (isListening) _buildEnhancedListeningIndicator(),
        ],
      ),
    );
  }

  Widget _buildEnhancedAIControls(bool isSpeakingPaused) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacityCompat(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacityCompat(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacityCompat(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSpeakingPaused ? Icons.pause_circle : Icons.record_voice_over,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isSpeakingPaused ? 'AI Speech Paused' : 'AI is Speaking',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAIControlButton(
                onPressed: () {
                  if (isSpeakingPaused) {
                    context.read<VoiceInterviewBloc>().add(ResumeSpeaking());
                  } else {
                    context.read<VoiceInterviewBloc>().add(PauseSpeaking());
                  }
                },
                icon: isSpeakingPaused ? Icons.play_arrow : Icons.pause,
                backgroundColor: Colors.orange,
                tooltip: isSpeakingPaused ? 'Resume AI' : 'Pause AI',
              ),
              const SizedBox(width: 16),
              _buildAIControlButton(
                onPressed: () {
                  context.read<VoiceInterviewBloc>().add(StopSpeaking());
                },
                icon: Icons.stop,
                backgroundColor: Colors.red,
                tooltip: 'Stop AI Speech',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color backgroundColor,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(28),
        child: FloatingActionButton(
          heroTag: "${tooltip}_button",
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          elevation: 0,
          mini: true,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEndInterviewButton() {
    return ElevatedButton.icon(
      onPressed: () => _showEndInterviewDialog(context),
      icon: const Icon(Icons.stop),
      label: const Text('End Interview'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEnhancedMicrophoneButton(bool isListening, bool canListen) {
    return AnimatedBuilder(
      animation: _listeningPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isListening ? _listeningPulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow:
                  isListening
                      ? [
                        BoxShadow(
                          color: Colors.red.withOpacityCompat(0.4),
                          blurRadius: 10 * _listeningPulseAnimation.value,
                          spreadRadius: 2 * _listeningPulseAnimation.value,
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withOpacityCompat(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(28),
              child: FloatingActionButton(
                heroTag: "mic_button",
                onPressed:
                    (canListen || isListening)
                        ? () {
                          if (isListening) {
                            context.read<VoiceInterviewBloc>().add(
                              StopListening(),
                            );
                          } else {
                            context.read<VoiceInterviewBloc>().add(
                              StartListening(),
                            );
                          }
                        }
                        : null,
                backgroundColor: isListening ? Colors.red : Colors.green,
                elevation: 0,
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedListeningIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacityCompat(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacityCompat(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacityCompat(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _listeningAnimationController,
            builder: (context, child) {
              return Icon(
                Icons.mic,
                color: Colors.red,
                size: 16 + (4 * _listeningAnimationController.value),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            'Listening...',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _micWaveController,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 2,
                  height:
                      8 +
                      (6 *
                          math
                              .sin(
                                (_micWaveController.value * 2 * math.pi) +
                                    (index * 0.8),
                              )
                              .abs()),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showEndInterviewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text('End Interview'),
              ],
            ),
            content: const Text(
              'Are you sure you want to end the interview? Your progress will be saved but the interview will be marked as incomplete.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Trigger interview completion instead of just going back
                  context.read<VoiceInterviewBloc>().add(CompleteInterview());
                },
                icon: const Icon(Icons.stop),
                label: const Text('End Interview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
