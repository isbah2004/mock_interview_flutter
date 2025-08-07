import 'package:flutter/material.dart';
// ...existing code...
import 'package:mock_interview/core/cubits/usercubit/user_cubit.dart';
import 'package:mock_interview/core/enums/difficulty_level.dart';
import 'package:mock_interview/core/enums/question_category.dart';
import 'package:mock_interview/features/interviews/presentation/cubit/mcq_counter_cubit.dart';
import 'package:mock_interview/features/interviews/presentation/cubit/mcq_counter_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_bloc.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_event.dart';
import 'package:mock_interview/features/interviews/presentation/bloc/mcq/mcq_interview_state.dart';
import 'package:mock_interview/features/interviews/presentation/widgets/question_card.dart';
import 'package:mock_interview/features/interviews/presentation/widgets/progress_indicator.dart';
import 'package:mock_interview/features/interviews/presentation/view/mcq_result_view.dart';

class MCQInterviewScreen extends StatefulWidget {
  final String jobRole;
  final DifficultyLevel difficulty;
  final QuestionCategory category;
  final int numberOfQuestions;
  final int timePerQuestion;

  const MCQInterviewScreen({
    super.key,
    required this.jobRole,
    required this.difficulty,
    required this.category,
    required this.numberOfQuestions,
    required this.timePerQuestion,
  });

  @override
  State<MCQInterviewScreen> createState() => _MCQInterviewScreenState();
}

class _MCQInterviewScreenState extends State<MCQInterviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  Duration timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    timeRemaining = Duration(seconds: widget.timePerQuestion);
    _progressController = AnimationController(
      duration: Duration(seconds: widget.timePerQuestion),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserCubit>().currentUser!.id;
      context.read<InterviewBloc>().add(
        StartInterviewEvent(
          userId: userId,
          jobRole: widget.jobRole,
          difficultyLevel: widget.difficulty,
          numQuestions: widget.numberOfQuestions,
          category: widget.category,
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startQuestionTimer(VoidCallback onTimeout) {
    timeRemaining = Duration(seconds: widget.timePerQuestion);
    _progressController.reset();
    _progressController.forward();
    final cubit = context.read<McqCounterCubit>();
    cubit.reset();
    cubit.start();
    // Timeout handled in BlocListener below
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit Interview?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          content: const Text(
            'Are you sure you want to exit? Your progress will be lost.',
            style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continue',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Exit',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<McqCounterCubit>(
      create: (_) => McqCounterCubit(),
      child: BlocConsumer<InterviewBloc, InterviewState>(
        listener: (context, state) {
          if (state is InterviewStarted) {
            _startQuestionTimer(() {
              final userId = context.read<UserCubit>().currentUser!.id;
              if (state.currentQuestionIndex <
                  state.interview.questions.length - 1) {
                context.read<InterviewBloc>().add(NextQuestionEvent());
              } else {
                context.read<InterviewBloc>().add(
                  SubmitInterviewEvent(
                    sessionId: state.interview.sessionId,
                    userId: userId,
                    answers: state.userAnswers,
                  ),
                );
              }
            });
          }
          if (state is InterviewCompleted) {
            context.read<McqCounterCubit>().stop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => InterviewResultScreen(
                  evaluationResult: state.evaluationResult,
                ),
              ),
            );
          }
          if (state is InterviewError) {
            context.read<McqCounterCubit>().stop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
        if (state is InterviewLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading Interview...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is InterviewError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is InterviewStarted) {
          final currentQuestion =
              state.interview.questions[state.currentQuestionIndex];
          final progress =
              (state.currentQuestionIndex + 1) /
              state.interview.questions.length;

          return BlocListener<McqCounterCubit, McqCounterState>(
            listener: (context, timerState) {
              final seconds = timerState.seconds;
              if (seconds >= McqCounterCubit.maxSeconds) {
                final userId = context.read<UserCubit>().currentUser!.id;
                if (state.currentQuestionIndex <
                    state.interview.questions.length - 1) {
                  context.read<InterviewBloc>().add(NextQuestionEvent());
                } else {
                  context.read<InterviewBloc>().add(
                    SubmitInterviewEvent(
                      sessionId: state.interview.sessionId,
                      userId: userId,
                      answers: state.userAnswers,
                    ),
                  );
                }
              } else {
                setState(() {
                  timeRemaining = Duration(seconds: (widget.timePerQuestion - seconds).clamp(0, widget.timePerQuestion));
                });
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              appBar: AppBar(
                title: const Text(
                  'MCQ Interview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _showExitDialog,
                ),
              ),
              body: Column(
                children: [
                  // Progress Indicator
                  InterviewProgressIndicator(
                    current: state.currentQuestionIndex + 1,
                    total: state.interview.questions.length,
                    progress: progress,
                    timeRemaining: timeRemaining,
                  ),

                  // Question Card
                  Expanded(
                    child: QuestionCard(
                      question: currentQuestion,
                      selectedAnswer:
                          state.userAnswers[state.currentQuestionIndex],
                      onAnswerSelected: (answer) {
                        context.read<InterviewBloc>().add(
                          SelectAnswerEvent(
                            questionIndex: state.currentQuestionIndex,
                            answer: answer,
                          ),
                        );
                      },
                      questionNumber: state.currentQuestionIndex + 1,
                      totalQuestions: state.interview.questions.length,
                    ),
                  ),

                  // Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Previous Button
                        if (state.currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<InterviewBloc>().add(
                                  PreviousQuestionEvent(),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                        if (state.currentQuestionIndex > 0)
                          const SizedBox(width: 16),

                        // Next/Submit Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _getNextAction(context, state),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              _isLastQuestion(state)
                                  ? 'Submit Interview'
                                  : 'Next Question',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Preparing Interview...',
                  style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
                ),
              ],
            ),
          ),
        );
      },
    ),);
  }

  VoidCallback? _getNextAction(BuildContext context, InterviewStarted state) {
    if (_isLastQuestion(state)) {
      return () => _submitInterview(context, state);
    } else {
      return () {
        context.read<InterviewBloc>().add(NextQuestionEvent());
      };
    }
  }

  bool _isLastQuestion(InterviewStarted state) {
    return state.currentQuestionIndex >= state.interview.questions.length - 1;
  }

  void _submitInterview(BuildContext context, InterviewStarted state) async {
    // Check if current question is answered
    final currentAnswer = state.userAnswers[state.currentQuestionIndex];

    // Check if there are any unanswered questions
    bool hasUnanswered = state.userAnswers.any((answer) => answer.isEmpty);

    if (hasUnanswered && currentAnswer.isEmpty) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Incomplete Interview'),
              content: const Text(
                'Some questions are not answered. Do you want to submit anyway?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            ),
      );

      if (shouldSubmit != true) return;
    }

    final userId = context.read<UserCubit>().currentUser!.id;
    context.read<InterviewBloc>().add(
      SubmitInterviewEvent(
        sessionId: state.interview.sessionId,
        userId: userId,
        answers: state.userAnswers,
      ),
    );
  }
}
