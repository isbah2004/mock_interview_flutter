import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mock_interview/core/theme/colorpalette/app_colors.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview/interview_bloc.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview/interview_event.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/bloc/interview/interview_state.dart';
import 'package:mock_interview/features/voiceinterviews/presentation/view/interview_result_view.dart';
import '../../domain/entities/interview_config.dart';
import '../../domain/entities/interview_message.dart';
import '../../domain/entities/interview_session.dart';
import '../../domain/usecases/start_interview_usecase.dart';
import '../../domain/usecases/send_response_usecase.dart';
import '../../domain/usecases/handle_speech_usecase.dart';

class VoiceInterviewView extends StatelessWidget {
  final InterviewConfig config;

  const VoiceInterviewView({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => InterviewBloc(
            GetIt.instance<StartInterviewUseCase>(),
            GetIt.instance<SendResponseUseCase>(),
            GetIt.instance<HandleSpeechUseCase>(),
          )..add(InitializeInterview(config)),
      child: VoiceInterviewScreen(config: config),
    );
  }
}

class VoiceInterviewScreen extends StatefulWidget {
  final InterviewConfig config;

  const VoiceInterviewScreen({super.key, required this.config});

  @override
  State<VoiceInterviewScreen> createState() =>
      _VoiceInterviewScreenState();
}

class _VoiceInterviewScreenState extends State<VoiceInterviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurple.withOpacity(0.1),
              AppColors.lightBackground,
              AppColors.lightSecondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<InterviewBloc, InterviewState>(
            listener: (context, state) {
              if (state is InterviewError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is InterviewInProgress &&
                  state.session.status == InterviewStatus.completed) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            InterviewResultView(
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
                  ),
                );
              }

              // Handle animation states
              if (state is InterviewInProgress) {
                if (state.session.isListening) {
                  _pulseController.repeat(reverse: true);
                  _waveController.repeat();
                } else {
                  _pulseController.stop();
                  _waveController.stop();
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(child: _buildChatInterface(state)),
                  _buildBottomControls(state, context),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatInterface(InterviewState state) {
    List<InterviewMessage> messages = [];

    if (state is InterviewInProgress) {
      messages = state.session.messages;
    }

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat, size: 48, color: AppColors.primaryPurple),
            ),
            const SizedBox(height: 16),
            Text(
              'Interview Starting...',
              style: TextStyle(
                color: AppColors.lightOnSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.type == MessageType.user;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isUser
                          ? [
                            AppColors.primaryPurple,
                            AppColors.primaryPurpleDark,
                          ]
                          : [
                            AppColors.lightSurface,
                            AppColors.lightSurface.withOpacity(0.8),
                          ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser
                            ? AppColors.primaryPurple
                            : AppColors.lightSecondary)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              isUser
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isUser ? Icons.person : Icons.smart_toy,
                          size: 12,
                          color:
                              isUser ? Colors.white : AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUser ? 'You' : 'AI Interviewer',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color:
                              isUser
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.primaryPurple,

                          fontWeight: FontWeight.w600,
                        ),

                        //  TextStyle(
                        //   color:
                        //       isUser
                        //           ? Colors.white.withOpacity(0.8)
                        //           : AppColors.primaryPurple,
                        //   fontSize: 10,
                        //   fontWeight: FontWeight.w600,
                        // ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.content,
                    style: TextStyle(
                      color:
                          isUser ? Colors.white : AppColors.lightOnBackground,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(InterviewState state, BuildContext context) {
    bool isListening = false;
    bool isSpeaking = false;
    bool canListen = false;

    if (state is InterviewInProgress) {
      isListening = state.session.isListening;
      isSpeaking = state.session.isSpeaking;
      canListen =
          !isSpeaking && state.session.status == InterviewStatus.inProgress;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryPurple.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.red.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () => _showEndInterviewDialog(context),
              icon: const Icon(Icons.stop, color: Colors.white, size: 18),
              label: const Text(
                'End',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors:
                          isListening
                              ? [Colors.red, Colors.red.shade700]
                              : canListen
                              ? [Colors.green, Colors.green.shade700]
                              : [
                                AppColors.lightOnSurface,
                                AppColors.lightOnSurface.withOpacity(0.7),
                              ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? Colors.red : Colors.green)
                            .withOpacity(0.4),
                        blurRadius: isListening ? 20 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed:
                        (canListen || isListening)
                            ? () {
                              if (isListening) {
                                context.read<InterviewBloc>().add(
                                  StopListening(),
                                );
                              } else {
                                context.read<InterviewBloc>().add(
                                  StartListening(),
                                );
                              }
                            }
                            : null,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child:
                        isSpeaking
                            ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            )
                            : Icon(
                              isListening ? Icons.stop : Icons.mic,
                              size: 32,
                              color: Colors.white,
                            ),
                  ),
                ),
              );
            },
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isListening
                      ? Colors.red.withOpacity(0.1)
                      : isSpeaking
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isListening
                        ? Colors.red
                        : isSpeaking
                        ? Colors.orange
                        : Colors.green,
                width: 1,
              ),
            ),
            child: Text(
              isListening
                  ? 'Listening...'
                  : isSpeaking
                  ? 'AI Speaking'
                  : 'Ready',
              style: TextStyle(
                color:
                    isListening
                        ? Colors.red
                        : isSpeaking
                        ? Colors.orange
                        : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEndInterviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'End Interview',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to end the interview?',
            style: TextStyle(color: AppColors.lightOnSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.lightOnSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'End Interview',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getQuestionNumber(InterviewState state) {
    if (state is InterviewInProgress) {
      return state.session.currentQuestionNumber;
    }
    return 1;
  }
}
